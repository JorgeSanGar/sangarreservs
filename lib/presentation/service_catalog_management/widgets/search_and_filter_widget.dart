import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SearchAndFilterWidget extends StatefulWidget {
  final String searchQuery;
  final String selectedCategory;
  final double minPrice;
  final double maxPrice;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<(double, double)> onPriceRangeChanged;

  const SearchAndFilterWidget({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.minPrice,
    required this.maxPrice,
    required this.categories,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onPriceRangeChanged,
  });

  @override
  State<SearchAndFilterWidget> createState() => _SearchAndFilterWidgetState();
}

class _SearchAndFilterWidgetState extends State<SearchAndFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  RangeValues _priceRange = const RangeValues(0, 500);

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar servicios...',
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              IconButton(
                icon: Icon(
                  _showFilters
                      ? Icons.filter_list_off_rounded
                      : Icons.filter_list_rounded,
                  color: _showFilters
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                tooltip: _showFilters ? 'Ocultar Filtros' : 'Mostrar Filtros',
              ),
            ],
          ),

          // Filters Section
          if (_showFilters) ...[
            SizedBox(height: 3.h),

            // Category Filter
            _buildCategoryFilter(colorScheme),

            SizedBox(height: 2.h),

            // Price Range Filter
            _buildPriceRangeFilter(colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // All Categories chip
              _buildCategoryChip(
                'all',
                'Todas',
                Icons.apps_rounded,
                colorScheme.primary,
                colorScheme,
              ),
              SizedBox(width: 2.w),

              // Individual category chips
              ...widget.categories.map((category) {
                return Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: _buildCategoryChip(
                    category['id'],
                    category['name'],
                    category['icon'],
                    category['color'],
                    colorScheme,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    String id,
    String name,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    final isSelected = widget.selectedCategory == id;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          SizedBox(width: 1.w),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : colorScheme.onSurface,
            ),
          ),
        ],
      ),
      onSelected: (selected) {
        widget.onCategoryChanged(selected ? id : 'all');
      },
      selectedColor: color,
      backgroundColor: colorScheme.surfaceContainerHighest,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildPriceRangeFilter(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rango de Precios',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '€${_priceRange.start.round()} - €${_priceRange.end.round()}',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 500,
          divisions: 50,
          labels: RangeLabels(
            '€${_priceRange.start.round()}',
            '€${_priceRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
          },
          onChangeEnd: (RangeValues values) {
            widget.onPriceRangeChanged((values.start, values.end));
          },
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
