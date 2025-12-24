import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/models/service_model.dart';

class ServiceManagementScreen extends StatefulWidget {
  final ShopModel shop;
  final bool embedded;

  const ServiceManagementScreen({
    super.key,
    required this.shop,
    this.embedded = false,
  });

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  // Default service names (always shown)
  static const List<Map<String, dynamic>> _defaultServiceTemplates = [
    {
      'name': 'Haircut',
      'icon': Icons.cut_rounded,
      'category': ServiceCategory.hair,
      'defaultPrice': 25.0,
      'defaultDuration': 30,
      'description': 'Classic haircut with styling',
    },
    {
      'name': 'Beard Trim',
      'icon': Icons.face_rounded,
      'category': ServiceCategory.beard,
      'defaultPrice': 15.0,
      'defaultDuration': 20,
      'description': 'Professional beard grooming',
    },
    {
      'name': 'Facial',
      'icon': Icons.spa_rounded,
      'category': ServiceCategory.face,
      'defaultPrice': 35.0,
      'defaultDuration': 45,
      'description': 'Relaxing facial treatment',
    },
    {
      'name': 'Massage',
      'icon': Icons.self_improvement_rounded,
      'category': ServiceCategory.body,
      'defaultPrice': 45.0,
      'defaultDuration': 60,
      'description': 'Full body relaxation massage',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: Default Services
          _buildSectionHeader("Services Menu", Icons.spa_rounded),
          const SizedBox(height: 16),

          // Default 4 Services Grid
          _buildDefaultServicesGrid(),

          const SizedBox(height: 32),

          // Section Header: Additional Services
          _buildSectionHeader("Additional Services", Icons.add_circle_outline_rounded),
          const SizedBox(height: 16),

          // Custom Services List
          _buildCustomServicesList(),

          // Add More Service Button
          _buildAddMoreServiceButton(),

          const SizedBox(height: 100),
        ],
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.primary,
        ),
        title: Text(
          "Services",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: content,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.rye(
            fontSize: 14,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: AppColors.divider),
        ),
      ],
    );
  }

  Widget _buildDefaultServicesGrid() {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<List<ServiceModel>>(
      stream: shopService.getServices(widget.shop.id),
      builder: (context, snapshot) {
        final services = snapshot.data ?? [];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _defaultServiceTemplates.length,
          itemBuilder: (context, index) {
            final template = _defaultServiceTemplates[index];

            // Find if this service exists in database
            final existingService = services.firstWhere(
              (s) => s.name.toLowerCase() == (template['name'] as String).toLowerCase(),
              orElse: () => ServiceModel(
                id: '',
                shopId: widget.shop.id,
                name: template['name'] as String,
                description: template['description'] as String,
                category: template['category'] as ServiceCategory,
                price: template['defaultPrice'] as double,
                durationMinutes: template['defaultDuration'] as int,
                createdAt: DateTime.now(),
              ),
            );

            return _buildDefaultServiceCard(
              template: template,
              service: existingService.id.isNotEmpty ? existingService : null,
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultServiceCard({
    required Map<String, dynamic> template,
    ServiceModel? service,
  }) {
    // Default is OFF - only enabled if service exists and isActive is true
    final isEnabled = service != null && service.id.isNotEmpty && service.isActive;
    final price = service?.price;

    return GestureDetector(
      onTap: () => _showDefaultServiceEditor(template, service),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? AppColors.success.withValues(alpha: 0.5) : AppColors.border,
            width: isEnabled ? 2 : 1,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          children: [
            // Toggle Button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _toggleDefaultService(template, service),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEnabled ? Icons.check_circle : Icons.circle_outlined,
                    size: 20,
                    color: isEnabled ? AppColors.success : AppColors.textTertiary,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      template['icon'] as IconData,
                      size: 24,
                      color: isEnabled ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    template['name'] as String,
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Price (if set)
                  if (price != null && price > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      "\$${price.toStringAsFixed(0)}",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      "Tap to set price",
                      style: GoogleFonts.crimsonText(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDefaultServiceEditor(Map<String, dynamic> template, ServiceModel? service) {
    // Only show price if already set (greater than 0)
    final hasExistingPrice = service != null && service.price > 0;
    final priceController = TextEditingController(
      text: hasExistingPrice ? service.price.toStringAsFixed(0) : '',
    );
    // Default is OFF - only ON if price was already set
    bool hasPriceEnabled = hasExistingPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          template['icon'] as IconData,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template['name'] as String,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              template['description'] as String,
                              style: GoogleFonts.crimsonText(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),

                const Divider(color: AppColors.divider, height: 1),

                // Price Toggle & Input
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              color: hasPriceEnabled ? AppColors.success : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add Price",
                                    style: GoogleFonts.crimsonText(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    hasPriceEnabled ? "Price is visible to customers" : "No price shown",
                                    style: GoogleFonts.crimsonText(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: hasPriceEnabled,
                              onChanged: (value) {
                                setModalState(() {
                                  hasPriceEnabled = value;
                                  if (!value) {
                                    priceController.clear();
                                  }
                                });
                              },
                              activeTrackColor: AppColors.success.withValues(alpha: 0.5),
                              activeThumbColor: AppColors.success,
                            ),
                          ],
                        ),
                      ),

                      // Price Input (only show when enabled)
                      if (hasPriceEnabled) ...[
                        const SizedBox(height: 16),
                        Text(
                          "Price",
                          style: GoogleFonts.crimsonText(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.ivory,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 2),
                          ),
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "0",
                              hintStyle: GoogleFonts.playfairDisplay(
                                color: AppColors.textTertiary,
                                fontSize: 28,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 16, right: 8),
                                child: Text(
                                  "\$",
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Save Button
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final shopService = context.read<ShopService>();
                          final navigator = Navigator.of(context);

                          final price = hasPriceEnabled
                              ? (double.tryParse(priceController.text) ?? 0)
                              : 0.0;

                          final newService = ServiceModel(
                            id: service?.id ?? '',
                            shopId: widget.shop.id,
                            name: template['name'] as String,
                            description: template['description'] as String,
                            category: template['category'] as ServiceCategory,
                            price: price,
                            durationMinutes: template['defaultDuration'] as int,
                            isActive: service?.isActive ?? true,
                            createdAt: service?.createdAt ?? DateTime.now(),
                          );

                          if (service != null && service.id.isNotEmpty) {
                            await shopService.updateService(newService);
                          } else {
                            await shopService.addService(newService);
                          }

                          navigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.gold,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "SAVE",
                          style: GoogleFonts.rye(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDefaultService(Map<String, dynamic> template, ServiceModel? service) async {
    final shopService = context.read<ShopService>();

    if (service != null && service.id.isNotEmpty) {
      // Toggle existing service
      await shopService.toggleServiceStatus(widget.shop.id, service.id, !service.isActive);
    } else {
      // Create new service (enable it)
      final newService = ServiceModel(
        id: '',
        shopId: widget.shop.id,
        name: template['name'] as String,
        description: template['description'] as String,
        category: template['category'] as ServiceCategory,
        price: 0, // No price initially
        durationMinutes: template['defaultDuration'] as int,
        isActive: true,
        createdAt: DateTime.now(),
      );
      await shopService.addService(newService);
    }
  }

  Widget _buildCustomServicesList() {
    final shopService = context.watch<ShopService>();

    return StreamBuilder<List<ServiceModel>>(
      stream: shopService.getServices(widget.shop.id),
      builder: (context, snapshot) {
        final services = snapshot.data ?? [];

        // Filter out default services
        final defaultNames = _defaultServiceTemplates.map((t) => (t['name'] as String).toLowerCase()).toList();
        final customServices = services.where((s) => !defaultNames.contains(s.name.toLowerCase())).toList();

        if (customServices.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.add_box_rounded, size: 40, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  "No additional services yet",
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Add custom services below",
                  style: GoogleFonts.crimsonText(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: customServices.map((service) => _buildCustomServiceCard(service)).toList(),
        );
      },
    );
  }

  Widget _buildCustomServiceCard(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: service.isActive ? AppColors.cardColor : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCustomServiceEditor(service),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: service.isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(service.category),
                    size: 22,
                    color: service.isActive ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: GoogleFonts.crimsonText(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: service.isActive ? AppColors.textPrimary : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "\$${service.price.toStringAsFixed(0)}",
                            style: GoogleFonts.crimsonText(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "• ${service.durationMinutes} min",
                            style: GoogleFonts.crimsonText(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status & Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: service.isActive
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service.isActive ? "Active" : "Off",
                        style: GoogleFonts.crimsonText(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: service.isActive ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.edit_rounded, size: 18, color: AppColors.textTertiary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreServiceButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showAddCustomServiceModal(),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          "Add More Service",
          style: GoogleFonts.crimsonText(fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showCustomServiceEditor(ServiceModel service) {
    final nameController = TextEditingController(text: service.name);
    final priceController = TextEditingController(text: service.price.toStringAsFixed(0));
    final durationController = TextEditingController(text: service.durationMinutes.toString());
    final descController = TextEditingController(text: service.description ?? '');
    ServiceCategory selectedCategory = service.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      "Edit Service",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Delete Button
                    IconButton(
                      onPressed: () => _deleteCustomService(service),
                      icon: const Icon(Icons.delete_rounded),
                      color: AppColors.error,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.divider, height: 1),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: nameController,
                        label: "Service Name",
                        hint: "e.g., Hair Color",
                        icon: Icons.spa_rounded,
                      ),
                      const SizedBox(height: 16),

                      // Category
                      Text(
                        "Category",
                        style: GoogleFonts.crimsonText(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ServiceCategory.values.map((category) {
                          final isSelected = selectedCategory == category;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedCategory = category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppColors.secondary : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(category),
                                    size: 16,
                                    color: isSelected ? AppColors.gold : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    ServiceModel.getCategoryName(category),
                                    style: GoogleFonts.crimsonText(
                                      fontSize: 12,
                                      color: isSelected ? AppColors.gold : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: priceController,
                              label: "Price (\$)",
                              hint: "25",
                              icon: Icons.attach_money_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: durationController,
                              label: "Duration (min)",
                              hint: "30",
                              icon: Icons.timer_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: descController,
                        label: "Description (Optional)",
                        hint: "Brief description",
                        icon: Icons.description_rounded,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      // Active Toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              service.isActive ? Icons.check_circle : Icons.circle_outlined,
                              color: service.isActive ? AppColors.success : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Service is ${service.isActive ? 'Active' : 'Inactive'}",
                                style: GoogleFonts.crimsonText(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Switch(
                              value: service.isActive,
                              onChanged: (value) {
                                context.read<ShopService>().toggleServiceStatus(
                                      widget.shop.id,
                                      service.id,
                                      value,
                                    );
                                Navigator.pop(context);
                              },
                              activeTrackColor: AppColors.success.withValues(alpha: 0.5),
                              activeThumbColor: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Save Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;

                        final shopService = context.read<ShopService>();
                        final navigator = Navigator.of(context);

                        final updatedService = service.copyWith(
                          name: nameController.text.trim(),
                          category: selectedCategory,
                          price: double.tryParse(priceController.text) ?? service.price,
                          durationMinutes: int.tryParse(durationController.text) ?? service.durationMinutes,
                          description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                        );

                        await shopService.updateService(updatedService);
                        navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("UPDATE SERVICE", style: GoogleFonts.rye(fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCustomServiceModal() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    final descController = TextEditingController();
    ServiceCategory selectedCategory = ServiceCategory.other;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      "Add New Service",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.divider, height: 1),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: nameController,
                        label: "Service Name",
                        hint: "e.g., Hair Color, Hot Towel Shave",
                        icon: Icons.spa_rounded,
                      ),
                      const SizedBox(height: 16),

                      // Category
                      Text(
                        "Category",
                        style: GoogleFonts.crimsonText(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ServiceCategory.values.map((category) {
                          final isSelected = selectedCategory == category;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedCategory = category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppColors.secondary : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(category),
                                    size: 16,
                                    color: isSelected ? AppColors.gold : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    ServiceModel.getCategoryName(category),
                                    style: GoogleFonts.crimsonText(
                                      fontSize: 12,
                                      color: isSelected ? AppColors.gold : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: priceController,
                              label: "Price (\$)",
                              hint: "25",
                              icon: Icons.attach_money_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: durationController,
                              label: "Duration (min)",
                              hint: "30",
                              icon: Icons.timer_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: descController,
                        label: "Description (Optional)",
                        hint: "Brief description of the service",
                        icon: Icons.description_rounded,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // Save Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter service name")),
                          );
                          return;
                        }

                        final shopService = context.read<ShopService>();
                        final navigator = Navigator.of(context);

                        final newService = ServiceModel(
                          id: '',
                          shopId: widget.shop.id,
                          name: nameController.text.trim(),
                          description: descController.text.trim().isNotEmpty ? descController.text.trim() : null,
                          category: selectedCategory,
                          price: double.tryParse(priceController.text) ?? 0,
                          durationMinutes: int.tryParse(durationController.text) ?? 30,
                          isActive: true,
                          createdAt: DateTime.now(),
                        );

                        await shopService.addService(newService);
                        navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("ADD SERVICE", style: GoogleFonts.rye(fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteCustomService(ServiceModel service) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error, width: 2),
        ),
        title: Text(
          "Delete Service",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Text(
          "Are you sure you want to delete '${service.name}'?",
          style: GoogleFonts.crimsonText(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancel",
              style: GoogleFonts.crimsonText(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              context.read<ShopService>().deleteService(widget.shop.id, service.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text("Delete", style: GoogleFonts.rye(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.crimsonText(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.ivory,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.crimsonText(fontSize: 16, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.crimsonText(color: AppColors.textTertiary),
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.hair:
        return Icons.cut_rounded;
      case ServiceCategory.beard:
        return Icons.face_rounded;
      case ServiceCategory.face:
        return Icons.spa_rounded;
      case ServiceCategory.body:
        return Icons.self_improvement_rounded;
      case ServiceCategory.other:
        return Icons.star_rounded;
    }
  }
}
