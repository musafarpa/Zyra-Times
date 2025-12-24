import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zyraslot/core/constants/app_colors.dart';
import 'package:zyraslot/features/auth/services/auth_service.dart';
import 'package:zyraslot/features/shop/services/shop_service.dart';
import 'package:zyraslot/models/shop_model.dart';
import 'package:zyraslot/widgets/location_picker_screen.dart';

class AddShopScreen extends StatefulWidget {
  const AddShopScreen({super.key});

  @override
  State<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  
  File? _imageFile;
  LatLng? _location;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result != null) {
      setState(() => _location = result);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_location == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location required"), backgroundColor: AppColors.error));
        return;
      }

      setState(() => _isLoading = true);
      try {
        final user = context.read<AuthService>().currentUser;
        if (user == null) throw Exception("Auth Error");

        final shop = ShopModel(
          id: '',
          ownerId: user.uid,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          address: _addressController.text.trim(),
          latitude: _location!.latitude,
          longitude: _location!.longitude,
          imageUrl: '',
          totalSeats: 0,
        );

        await context.read<ShopService>().addShop(shop, _imageFile);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"), backgroundColor: AppColors.error));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("New Establishment", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        actions: [
            IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => context.read<AuthService>().logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textSecondary),
                            const SizedBox(height: 8),
                            Text("Add Cover Photo", style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              _buildInput("Shop Name", _nameController),
              const SizedBox(height: 16),
              _buildInput("Description", _descController, maxLines: 3),
              const SizedBox(height: 16),
              _buildInput("Address", _addressController),
              const SizedBox(height: 24),
              
              InkWell(
                onTap: _pickLocation,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _location != null ? AppColors.primary : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.map_outlined, color: _location != null ? AppColors.primary : AppColors.textSecondary),
                      const SizedBox(width: 16),
                      Text(
                        _location != null ? "Location Selected" : "Select on Map",
                        style: GoogleFonts.outfit(
                          color: _location != null ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text("Create Establishment"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.outfit(),
      validator: (val) => val!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}
