-- Location: supabase/migrations/20250901213000_add_tire_service_timing.sql
-- Schema Analysis: Building upon existing services, orgs, and duration_stats tables
-- Integration Type: Enhancement - Adding vehicle type support and tire timing recommendations
-- Dependencies: services, orgs, duration_stats

-- 1. Create vehicle type enum for tire services
CREATE TYPE public.vehicle_type AS ENUM (
  'turismo',
  'suv_4x4', 
  'todoterreno_puro',
  'camion',
  'furgoneta_SRW',
  'furgoneta_DRW'
);

-- 2. Add vehicle-specific columns to existing services table
ALTER TABLE public.services 
ADD COLUMN vehicle_type public.vehicle_type,
ADD COLUMN wheel_count INTEGER,
ADD COLUMN with_balancing BOOLEAN DEFAULT false,
ADD COLUMN use_recommended_timing BOOLEAN DEFAULT false,
ADD COLUMN timing_metadata JSONB;

-- 3. Create tire timing recommendations table
CREATE TABLE public.tire_timing_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_type public.vehicle_type NOT NULL,
    description TEXT NOT NULL,
    base_times JSONB NOT NULL,
    balancing_times JSONB,
    balancing_supplement NUMERIC,
    unit TEXT DEFAULT 'min',
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(vehicle_type)
);

-- 4. Create index for performance
CREATE INDEX idx_tire_timing_recommendations_vehicle_type ON public.tire_timing_recommendations(vehicle_type);
CREATE INDEX idx_services_vehicle_type ON public.services(vehicle_type);
CREATE INDEX idx_services_wheel_count ON public.services(wheel_count);

-- 5. Enable RLS
ALTER TABLE public.tire_timing_recommendations ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policy using Pattern 4 (Public Read, Private Write)
CREATE POLICY "public_can_read_tire_timing_recommendations"
ON public.tire_timing_recommendations
FOR SELECT 
TO public 
USING (true);

CREATE POLICY "org_members_manage_tire_timing_recommendations"
ON public.tire_timing_recommendations
FOR ALL 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.org_members om
        WHERE om.user_id = auth.uid()
        AND om.role IN ('admin', 'manager')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.org_members om
        WHERE om.user_id = auth.uid()
        AND om.role IN ('admin', 'manager')
    )
);

-- 7. Add trigger for updated_at
CREATE TRIGGER update_tire_timing_recommendations_updated_at
    BEFORE UPDATE ON public.tire_timing_recommendations
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 8. Insert tire timing recommendations data
INSERT INTO public.tire_timing_recommendations (
    vehicle_type, description, base_times, balancing_times, balancing_supplement, unit, note
) VALUES
(
    'turismo'::public.vehicle_type,
    'Coche turismo (compacto/berlina). Tiempos medios totales en minutos (min).',
    '{"1_rueda": 15.0, "2_ruedas": 25.1, "3_ruedas": 37.1, "4_ruedas": 50.2}'::jsonb,
    NULL,
    NULL,
    'min',
    NULL
),
(
    'suv_4x4'::public.vehicle_type,
    'SUV o 4x4 ligero. Ruedas de mayor tamaño y peso. Tiempos medios totales en minutos (min).',
    '{"1_rueda": 25.0, "2_ruedas": 50.0, "3_ruedas": 69.9, "4_ruedas": 90.0}'::jsonb,
    NULL,
    NULL,
    'min',
    NULL
),
(
    'todoterreno_puro'::public.vehicle_type,
    'Todoterreno con neumático AT/MT (más duro, más pesado). Tiempos medios totales en minutos (min).',
    '{"1_rueda": 28.0, "2_ruedas": 55.0, "3_ruedas": 77.0, "4_ruedas": 100.0}'::jsonb,
    NULL,
    NULL,
    'min',
    NULL
),
(
    'camion'::public.vehicle_type,
    'Camión. Neumáticos de gran volumen. Incluye inflado más largo. Tiempos medios totales en minutos (min).',
    '{"1_rueda": 25.0, "2_ruedas": 47.8, "3_ruedas": 70.7, "4_ruedas": 93.8}'::jsonb,
    '{"2_ruedas": 67.8, "4_ruedas": 113.8}'::jsonb,
    NULL,
    'min',
    NULL
),
(
    'furgoneta_SRW'::public.vehicle_type,
    'Furgoneta (vehículo comercial ligero) con rueda simple trasera. Progresión hasta 4 neumáticos.',
    '{"1_rueda": 23.4, "2_ruedas": 42.6, "3_ruedas": 63.2, "4_ruedas": 84.6}'::jsonb,
    '{"1_rueda": 43.4, "2_ruedas": 62.6, "3_ruedas": 83.2, "4_ruedas": 104.6}'::jsonb,
    20.0,
    'min',
    NULL
),
(
    'furgoneta_DRW'::public.vehicle_type,
    'Furgoneta gran volumen con rueda gemela en eje trasero (dual rear wheel). Progresión hasta 6 neumáticos.',
    '{"1_rueda": 23.2, "2_ruedas": 43.1, "3_ruedas": 63.7, "4_ruedas": 84.8, "5_ruedas": 106.2, "6_ruedas": 127.8}'::jsonb,
    '{"1_rueda": 43.2, "2_ruedas": 63.1, "3_ruedas": 83.7, "4_ruedas": 104.8, "5_ruedas": 126.2, "6_ruedas": 147.8}'::jsonb,
    20.0,
    'min',
    'Si las ruedas delanteras se cambian, su equilibrado ya está incluido y no se suma el suplemento.'
);

-- 9. Create helper function to get recommended timing
CREATE OR REPLACE FUNCTION public.get_tire_timing_recommendation(
    p_vehicle_type public.vehicle_type,
    p_wheel_count INTEGER,
    p_with_balancing BOOLEAN DEFAULT false
)
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    wheel_key TEXT;
    result NUMERIC;
    recommendation RECORD;
BEGIN
    -- Validate inputs
    IF p_wheel_count IS NULL OR p_wheel_count < 1 OR p_wheel_count > 6 THEN
        RETURN NULL;
    END IF;
    
    -- Get recommendation record
    SELECT * INTO recommendation 
    FROM public.tire_timing_recommendations ttr
    WHERE ttr.vehicle_type = p_vehicle_type;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    
    -- Build wheel key
    wheel_key := p_wheel_count || '_rueda' || CASE WHEN p_wheel_count > 1 THEN 's' ELSE '' END;
    
    -- Get timing from appropriate source
    IF p_with_balancing AND recommendation.balancing_times IS NOT NULL THEN
        result := (recommendation.balancing_times ->> wheel_key)::NUMERIC;
    ELSE
        result := (recommendation.base_times ->> wheel_key)::NUMERIC;
    END IF;
    
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$;

-- 10. Create function to update service duration based on tire recommendations
CREATE OR REPLACE FUNCTION public.update_service_duration_from_tire_recommendation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    recommended_duration NUMERIC;
BEGIN
    -- Only process if this is a tire service with recommendations enabled
    IF NEW.use_recommended_timing = true 
       AND NEW.vehicle_type IS NOT NULL 
       AND NEW.wheel_count IS NOT NULL THEN
        
        -- Get recommended duration
        recommended_duration := public.get_tire_timing_recommendation(
            NEW.vehicle_type,
            NEW.wheel_count,
            COALESCE(NEW.with_balancing, false)
        );
        
        -- Update duration if recommendation found
        IF recommended_duration IS NOT NULL THEN
            NEW.duration_min := recommended_duration::INTEGER;
            
            -- Store metadata about the recommendation
            NEW.timing_metadata := jsonb_build_object(
                'recommended_duration', recommended_duration,
                'vehicle_type', NEW.vehicle_type,
                'wheel_count', NEW.wheel_count,
                'with_balancing', COALESCE(NEW.with_balancing, false),
                'updated_at', CURRENT_TIMESTAMP
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

-- 11. Create trigger to automatically update service duration
CREATE TRIGGER update_service_duration_from_recommendations
    BEFORE INSERT OR UPDATE ON public.services
    FOR EACH ROW 
    WHEN (NEW.use_recommended_timing = true AND NEW.vehicle_type IS NOT NULL AND NEW.wheel_count IS NOT NULL)
    EXECUTE FUNCTION public.update_service_duration_from_tire_recommendation();

-- 12. Comment on new objects
COMMENT ON TYPE public.vehicle_type IS 'Vehicle types for tire service timing recommendations';
COMMENT ON TABLE public.tire_timing_recommendations IS 'Predefined timing recommendations for tire services based on vehicle type';
COMMENT ON FUNCTION public.get_tire_timing_recommendation IS 'Get recommended service duration for tire services based on vehicle type and wheel count';