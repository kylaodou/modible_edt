import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modible_edt/core/theme/colors.dart';
import 'package:modible_edt/models/apiResponse.dart';
import 'package:modible_edt/services/ProfileService.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

class EditProfilePhotoPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfilePhotoPage({Key? key, this.userData}) : super(key: key);

  @override
  State<EditProfilePhotoPage> createState() => _EditProfilePhotoPageState();
}

class _EditProfilePhotoPageState extends State<EditProfilePhotoPage> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentPhoto();
  }

  void _loadCurrentPhoto() {
    if (widget.userData != null && 
        widget.userData!['data'] != null && 
        widget.userData!['data']['user'] != null) {
      setState(() {
        _currentPhotoUrl = widget.userData!['data']['user']['photoURL'];
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compression pour réduire la taille
        maxWidth: 800,
      );
      
      if (image != null) {
        final croppedImage = await _cropImage(File(image.path));
        if (croppedImage != null) {
          setState(() {
            _selectedImage = croppedImage;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sélection de l\'image: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _takePhotoWithCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 800,
      );
      
      if (image != null) {
        final croppedImage = await _cropImage(File(image.path));
        if (croppedImage != null) {
          setState(() {
            _selectedImage = croppedImage;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la prise de photo: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressQuality: 70,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer l\'image',
          toolbarColor: primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Recadrer l\'image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  Future<void> _updateProfilePhoto() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner une image';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Envoyer direct ement le fichier image
      ApiResponse response = await _profileService.updateProfilePhoto(_selectedImage!);

      if (response.success) {
        // Afficher un message de  succès et retourner à la page précédente
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Photo de profil mise à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retourner true pour indiquer que la photo a été mise à jour
        }
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Erreur lors de la mise à jour de la photo de profil';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la photo de profil'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Afficher l'image actuelle ou l'image sélectionnée
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                            ),
                          )
                        : _currentPhotoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  _currentPhotoUrl!,
                                  fit: BoxFit.cover,
                                  width: 200,
                                  height: 200,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        FontAwesomeIcons.user,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  FontAwesomeIcons.user,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Afficher un message d'erreur s'il y en a un
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Boutons pour sélectionner une image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: FontAwesomeIcons.images,
                        label: 'Galerie',
                        onTap: _pickImageFromGallery,
                        color: const Color(0xFF1A73E8),
                      ),
                      _buildActionButton(
                        icon: FontAwesomeIcons.camera,
                        label: 'Caméra',
                        onTap: _takePhotoWithCamera,
                        color: const Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Bouton pour mettre à jour la photo
                  ElevatedButton(
                    onPressed: _selectedImage != null ? _updateProfilePhoto : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Mettre à jour la photo',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
