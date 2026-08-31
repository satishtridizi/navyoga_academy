import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/student_model.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/services/auth_service.dart';
import 'package:navyoga_academy/services/profile_service.dart';
import 'package:navyoga_academy/utils/api_helper.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final genderController = TextEditingController();
  final ageController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final medicalConditionsController = TextEditingController();
  final yogaExperienceController = TextEditingController();
  final currentLevelController = TextEditingController();
  final areasOfInterestController = TextEditingController();

  StudentModel? student;
  File? selectedImage;
  String? profileImageUrl;

  bool isLoading = true;
  bool isUpdating = false;
  bool isUploadingImage = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await AuthManager.getToken();

      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (_) => false,
        );
        return;
      }

      final response = await _authService.getProfile(token);

      if (response['unauthorized'] == true) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (_) => false,
        );
        return;
      }

      if (!ApiHelper.isSuccess(response) || response['data'] == null) {
        throw Exception(
          response['message']?.toString() ?? 'Unable to load profile.',
        );
      }

      final rawData = Map<String, dynamic>.from(response['data']);
      final studentData = StudentModel.fromJson(rawData);
      debugPrint('RAW AVATAR => ${rawData['avatar']}');
debugPrint('FINAL AVATAR URL => ${studentData.avatar}');

      if (!mounted) return;

      setState(() {
        student = studentData;
        profileImageUrl = studentData.avatar;
        selectedImage = null;

        nameController.text = studentData.name;
        emailController.text = studentData.email;
        phoneController.text = studentData.phone;
        cityController.text = studentData.city ?? '';
        countryController.text = studentData.country ?? '';
        genderController.text = studentData.gender ?? '';
        ageController.text = studentData.age?.toString() ?? '';
        bloodGroupController.text = studentData.bloodGroup ?? '';
        emergencyContactController.text =
            studentData.emergencyContact ?? '';
        medicalConditionsController.text =
            studentData.medicalConditions ?? '';
        yogaExperienceController.text =
            studentData.yogaExperience ?? '';
        currentLevelController.text = studentData.currentLevel ?? '';
        areasOfInterestController.text =
            studentData.areasOfInterest ?? '';
      });

      debugPrint('PROFILE DATA => $rawData');
    } catch (error, stackTrace) {
      debugPrint('LOAD PROFILE ERROR => $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to load your profile. Please try again.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1200,
      );

      if (image == null || !mounted) return;

      setState(() {
        selectedImage = File(image.path);
      });

      await uploadProfileImage();
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Unable to select the image.');
    }
  }

  Future<void> uploadProfileImage() async {
    if (selectedImage == null || isUploadingImage) return;

    final token = await AuthManager.getToken();

    if (token == null || token.trim().isEmpty) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (_) => false,
      );
      return;
    }

    setState(() {
      isUploadingImage = true;
    });

    try {
      final response = await _profileService.uploadProfileImage(
        token: token,
        imageFile: selectedImage!,
      );

      if (!mounted) return;

      if (ApiHelper.isSuccess(response)) {
        AppSnackbar.showSuccess(
          context,
          response['message']?.toString() ?? 'Profile photo updated.',
        );
        await loadProfile();
      } else {
        AppSnackbar.showError(
          context,
          response['message']?.toString() ??
              'Unable to update profile photo.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Unable to update profile photo.');
    } finally {
      if (!mounted) return;
      setState(() {
        isUploadingImage = false;
      });
    }
  }

  Future<void> updateProfile() async {
    if (isUpdating) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      AppSnackbar.showError(
        context,
        'Name, email and phone number are required.',
      );
      return;
    }

    final ageText = ageController.text.trim();
    final age = ageText.isEmpty ? null : int.tryParse(ageText);

    if (ageText.isNotEmpty && age == null) {
      AppSnackbar.showError(context, 'Please enter a valid age.');
      return;
    }

    final token = await AuthManager.getToken();

    if (token == null || token.trim().isEmpty) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (_) => false,
      );
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final response = await _profileService.updateProfile(
        token: token,
        name: name,
        email: email,
        phone: phone,
        city: cityController.text,
        country: countryController.text,
        gender: genderController.text,
        age: age,
        bloodGroup: bloodGroupController.text,
        emergencyContact: emergencyContactController.text,
        medicalConditions: medicalConditionsController.text,
        yogaExperience: yogaExperienceController.text,
        currentLevel: currentLevelController.text,
        areasOfInterest: areasOfInterestController.text,
      );

      if (!mounted) return;

      if (ApiHelper.isSuccess(response)) {
        AppSnackbar.showSuccess(
          context,
          response['message']?.toString() ?? 'Profile updated successfully.',
        );
        await loadProfile();
      } else {
        AppSnackbar.showError(
          context,
          response['message']?.toString() ?? 'Unable to update profile.',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('UPDATE PROFILE ERROR => $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      AppSnackbar.showError(context, 'Unable to update profile.');
    } finally {
      if (!mounted) return;

      setState(() {
        isUpdating = false;
      });
    }
  }

  String get memberSince {
    final createdAt = student?.createdAt;
    final date = DateTime.tryParse(createdAt ?? '');

    if (date == null) return 'Member';

    return 'Member since ${DateFormat('MMM yyyy').format(date.toLocal())}';
  }

  String get displayName {
    final value = nameController.text.trim();
    return value.isEmpty ? 'Student' : value;
  }

  String get initials {
    final words = displayName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return 'S';
    if (words.length == 1) return words.first[0].toUpperCase();

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    countryController.dispose();
    genderController.dispose();
    ageController.dispose();
    bloodGroupController.dispose();
    emergencyContactController.dispose();
    medicalConditionsController.dispose();
    yogaExperienceController.dispose();
    currentLevelController.dispose();
    areasOfInterestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 4,
      drawer: const CustomDrawer(currentPage: 'Profile'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (errorMessage != null) _buildErrorCard(),
                    _buildProfileHeader(),
                    const SizedBox(height: 18),
                    _buildSection(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                          _buildTextField(
                            controller: emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _buildTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            suffix: student?.phoneVerified == true
                                ? const Tooltip(
                                    message: 'Phone verified',
                                    child: Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                    ),
                                  )
                                : null,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: cityController,
                                  label: 'City',
                                  icon: Icons.location_city_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: countryController,
                                  label: 'Country',
                                  icon: Icons.public,
                                ),
                              ),
                            ],
                          ),
                          _buildDropdownField(
                            controller: genderController,
                            label: 'Gender',
                            icon: Icons.wc_outlined,
                            options: const ['Male', 'Female', 'Other', 'Prefer not to say'],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Medical Information',
                      icon: Icons.medical_information_outlined,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: ageController,
                                  label: 'Age',
                                  icon: Icons.cake_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdownField(
                                  controller: bloodGroupController,
                                  label: 'Blood Group',
                                  icon: Icons.bloodtype_outlined,
                                  options: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                                ),
                              ),
                            ],
                          ),
                          _buildTextField(
                            controller: emergencyContactController,
                            label: 'Emergency Contact',
                            icon: Icons.emergency_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildTextField(
                            controller: medicalConditionsController,
                            label: 'Medical Conditions',
                            icon: Icons.health_and_safety_outlined,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Yoga Preferences',
                      icon: Icons.self_improvement,
                      child: Column(
                        children: [
                          _buildDropdownField(
                            controller: yogaExperienceController,
                            label: 'Yoga Experience',
                            icon: Icons.history_toggle_off,
                            options: const ['Beginner', '< 1 Year', '1-3 Years', '3-5 Years', '5+ Years'],
                          ),
                          _buildDropdownField(
                            controller: currentLevelController,
                            label: 'Current Level',
                            icon: Icons.trending_up,
                            options: const ['Basic', 'Intermediate', 'Advanced'],
                          ),
                          _buildTextField(
                            controller: areasOfInterestController,
                            label: 'Areas of Interest',
                            icon: Icons.interests_outlined,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isUpdating ? null : updateProfile,
                        icon: isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          isUpdating ? 'Updating Profile...' : 'Save Changes',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              Colors.deepOrange.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange.shade400,
            Colors.deepOrange.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$greeting, ${displayName.split(' ').first}!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: isUploadingImage ? null : pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 116,
                  height: 116,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(child: _buildAvatarImage()),
                ),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepOrange.shade100,
                    ),
                  ),
                  child: isUploadingImage
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.deepOrange,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: Colors.deepOrange,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            student?.email ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeaderBadge(
                icon: student?.isActive == true
                    ? Icons.check_circle
                    : Icons.cancel,
                text: student?.isActive == true
                    ? 'Active Account'
                    : 'Inactive Account',
              ),
              _buildHeaderBadge(
                icon: Icons.calendar_today_outlined,
                text: memberSince,
              ),
              if ((student?.referralCode ?? '').isNotEmpty)
                _buildHeaderBadge(
                  icon: Icons.card_giftcard,
                  text: student!.referralCode!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (selectedImage != null) {
      return Image.file(selectedImage!, fit: BoxFit.cover);
    }

    if (profileImageUrl != null && profileImageUrl!.trim().isNotEmpty) {
      return Image.network(
        profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitialAvatar(),
      );
    }

    return _buildInitialAvatar();
  }

  Widget _buildInitialAvatar() {
    return Container(
      color: Colors.deepOrange.shade50,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
    );
  }

  Widget _buildHeaderBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.deepOrange),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textCapitalization: keyboardType == TextInputType.emailAddress
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.deepOrange,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> options,
  }) {
    final currentVal = controller.text.trim();
    final validVal = options.contains(currentVal) ? currentVal : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: validVal,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepOrange),
          ),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: '',
            child: Text(
              '-- None / Not Specified --',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ...options.map((opt) => DropdownMenuItem<String>(
                value: opt,
                child: Text(
                  opt,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
        onChanged: (val) {
          setState(() {
            controller.text = val ?? '';
          });
        },
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(errorMessage!)),
          TextButton(
            onPressed: loadProfile,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
