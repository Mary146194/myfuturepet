import 'package:flutter/material.dart';
import '../adoption_application_store.dart';
import '../services/adoption_service.dart';

class AdoptionProcessScreen extends StatefulWidget {
  final Map<String, dynamic> pet;
  final AdoptionService? adoptionService;

  const AdoptionProcessScreen({
    super.key,
    required this.pet,
    this.adoptionService,
  });

  @override
  State<AdoptionProcessScreen> createState() =>
      _AdoptionProcessScreenState();
}

class _AdoptionProcessScreenState
    extends State<AdoptionProcessScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFA94327);
  static const Color darkText = Color(0xFF062B35);
  static const Color backgroundColor = Color(0xFFEFF9FD);
  static const Color borderColor = Color(0xFFD7E3E7);
  static const Color secondaryText = Color(0xFF68777C);
  static const Color lightPrimary = Color(0xFFFFF4EF);
  static const Color lightBlue = Color(0xFFE4F5FB);

  // ============================================================
  // CURRENT STEP
  // ============================================================

  int currentStep = 0;

  // ============================================================
  // FORM CONTROLLERS
  // ============================================================

  // STEP 1
  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController ageController =
      TextEditingController();

  final TextEditingController occupationController =
      TextEditingController();

  // STEP 2
  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController householdMembersController =
      TextEditingController();

  final TextEditingController childrenController =
      TextEditingController();

  // STEP 3
  final TextEditingController previousPetsController =
      TextEditingController();

  final TextEditingController currentPetsController =
      TextEditingController();

  // STEP 4
  final TextEditingController timeAvailableController =
      TextEditingController();

  // STEP 5
  final TextEditingController adoptionReasonController =
      TextEditingController();

  // ============================================================
  // DROPDOWN VALUES
  // ============================================================

  String? householdType;
  String? yardAvailability;
  String? experienceLevel;
  String? homeEnvironment;
  String? activityLevel;

  bool agreementAccepted = false;

  // ============================================================
  // STEP TITLES
  // ============================================================

  final List<String> stepTitles = [
    'Personal Information',
    'Household Information',
    'Pet Experience',
    'Lifestyle & Preferences',
    'Adoption Preferences',
    'Review & Submit',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    ageController.dispose();
    occupationController.dispose();

    addressController.dispose();
    householdMembersController.dispose();
    childrenController.dispose();

    previousPetsController.dispose();
    currentPetsController.dispose();

    timeAvailableController.dispose();

    adoptionReasonController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: _submitting ? null : _confirmExit,
          icon: const Icon(
            Icons.close_rounded,
            color: darkText,
            size: 24,
          ),
        ),

        title: const Text(
          'Adoption Application',
          style: TextStyle(
            color: darkText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          const SizedBox(width: 48),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          // PROGRESS
          _buildProgress(),

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                30,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // STEP NUMBER
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: lightPrimary,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),

                    child: Text(
                      'STEP ${currentStep + 1} OF 6',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // STEP TITLE
                  Text(
                    stepTitles[currentStep],
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DESCRIPTION
                  Text(
                    _getStepDescription(),
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // STEP CONTENT
                  _buildCurrentStep(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // BOTTOM BUTTONS
          _buildBottomButton(),
        ],
      ),
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        16,
      ),

      child: Row(
        children: List.generate(
          6,
          (index) {
            final bool completed =
                index <= currentStep;

            return Expanded(
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 250),

                height: 5,

                margin: EdgeInsets.only(
                  right: index == 4 ? 0 : 4,
                ),

                decoration: BoxDecoration(
                  color: completed
                      ? primaryColor
                      : const Color(0xFFD5E2E6),

                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // STEP DESCRIPTION
  // ============================================================

  String _getStepDescription() {
    switch (currentStep) {
      case 0:
        return 'Let’s start with the basics to help us match you with your perfect companion.';

      case 1:
        return 'Tell us about your home and the people or pets who will be living with your new companion.';

      case 2:
        return 'Help us understand your experience caring for pets.';

      case 3:
        return 'Tell us about your daily routine and the environment your pet will live in.';

      case 4:
        return 'Tell us why you want to adopt and what you expect from the adoption process.';

      case 5:
        return 'Review your application and confirm that the information you provided is correct.';

      default:
        return '';
    }
  }

  // ============================================================
  // CURRENT STEP
  // ============================================================

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildPersonalInformation();

      case 1:
        return _buildHouseholdInformation();

      case 2:
        return _buildPetExperience();

      case 3:
        return _buildLifestylePreferences();

      case 4:
        return _buildAdoptionPreferences();

      case 5:
        return _buildReviewSubmit();

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // STEP 1
  // PERSONAL INFORMATION
  // ============================================================

  Widget _buildPersonalInformation() {
    return Column(
      children: [
        _buildTextField(
          controller: fullNameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline_rounded,
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller: phoneController,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          keyboardType: TextInputType.phone,
          icon: Icons.phone_outlined,
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller: emailController,
          label: 'Email Address',
          hint: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: ageController,
                label: 'Age',
                hint: 'Age',
                keyboardType: TextInputType.number,
                icon: Icons.cake_outlined,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildTextField(
                controller: occupationController,
                label: 'Occupation',
                hint: 'Occupation',
                icon: Icons.work_outline_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2
  // HOUSEHOLD INFORMATION
  // ============================================================

  Widget _buildHouseholdInformation() {
    return Column(
      children: [
        _buildDropdown(
          value: householdType,
          label: 'Household Type',
          hint: 'Select household type',
          items: const [
            'House',
            'Apartment',
            'Condominium',
            'Townhouse',
            'Other',
          ],
          onChanged: (value) {
            setState(() {
              householdType = value;
            });
          },
        ),

        const SizedBox(height: 14),

        _buildDropdown(
          value: yardAvailability,
          label: 'Yard Availability',
          hint: 'Select yard availability',
          items: const ['Fenced yard', 'Unfenced yard', 'No yard'],
          onChanged: (value) => setState(() => yardAvailability = value),
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: addressController,
          label: 'Complete Address',
          hint: 'Enter your complete address',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller:
                    householdMembersController,
                label: 'Household Members',
                hint: 'Number',
                keyboardType:
                    TextInputType.number,
                icon:
                    Icons.people_outline_rounded,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildTextField(
                controller: childrenController,
                label: 'Children',
                hint: 'Number',
                keyboardType:
                    TextInputType.number,
                icon:
                    Icons.child_friendly_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _buildInfoCard(
          icon: Icons.home_outlined,
          title: 'Home Environment',
          description:
              'Please provide accurate information about where your adopted pet will stay.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 3
  // PET EXPERIENCE
  // ============================================================

  Widget _buildPetExperience() {
    return Column(
      children: [
        _buildDropdown(
          value: experienceLevel,
          label: 'Pet Experience Level',
          hint: 'Select your experience',
          items: const [
            'First-time pet owner',
            'Some experience',
            'Experienced pet owner',
            'Very experienced',
          ],
          onChanged: (value) {
            setState(() {
              experienceLevel = value;
            });
          },
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller: previousPetsController,
          label: 'Previous Pets',
          hint:
              'Tell us about pets you have cared for before',
          maxLines: 4,
          icon: Icons.pets_outlined,
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller: currentPetsController,
          label: 'Current Pets',
          hint:
              'Tell us about your current pets',
          maxLines: 4,
          icon:
              Icons.cruelty_free_outlined,
        ),

        const SizedBox(height: 18),

        _buildInfoCard(
          icon: Icons.favorite_outline,
          title: 'Pet Care Experience',
          description:
              'Tell us about your previous or current experience caring for animals.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 4
  // LIFESTYLE & PREFERENCES
  // ============================================================

  Widget _buildLifestylePreferences() {
    return Column(
      children: [
        _buildDropdown(
          value: homeEnvironment,
          label: 'Home Environment',
          hint: 'Select your home environment',
          items: const [
            'Quiet',
            'Moderately Active',
            'Very Active',
          ],
          onChanged: (value) {
            setState(() {
              homeEnvironment = value;
            });
          },
        ),

        const SizedBox(height: 14),

        _buildDropdown(
          value: activityLevel,
          label: 'Activity Level',
          hint: 'Select your activity level',
          items: const [
            'Low',
            'Moderate',
            'High',
          ],
          onChanged: (value) {
            setState(() {
              activityLevel = value;
            });
          },
        ),

        const SizedBox(height: 14),

        _buildTextField(
          controller: timeAvailableController,
          label: 'Daily Time Available',
          hint:
              'How much time can you spend with your pet each day?',
          maxLines: 4,
          icon:
              Icons.access_time_outlined,
        ),

        const SizedBox(height: 18),

        _buildInfoCard(
          icon: Icons.schedule_outlined,
          title: 'Daily Routine',
          description:
              'Consider feeding, exercise, training, grooming, and companionship.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 5
  // ADOPTION PREFERENCES
  // ============================================================

  Widget _buildAdoptionPreferences() {
    return Column(
      children: [
        _buildPetPreviewCard(),

        const SizedBox(height: 18),

        _buildTextField(
          controller: adoptionReasonController,
          label: 'Why do you want to adopt?',
          hint:
              'Tell us why you want to adopt this pet...',
          maxLines: 6,
          icon:
              Icons.favorite_border_rounded,
        ),

        const SizedBox(height: 18),

        _buildAgreementCard(),
      ],
    );
  }

  // ============================================================
  // AGREEMENT CARD
  // ============================================================

  Widget _buildAgreementCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: agreementAccepted
              ? primaryColor
              : borderColor,
          width: agreementAccepted ? 1.5 : 1,
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Checkbox(
            value: agreementAccepted,
            activeColor: primaryColor,

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(5),
            ),

            onChanged: (value) {
              setState(() {
                agreementAccepted =
                    value ?? false;
              });
            },
          ),

          const SizedBox(width: 6),

          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4),

              child: Text(
                'I understand that adopting a pet is a long-term responsibility and I agree to provide proper care, food, shelter, veterinary care, and a safe environment.',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 6
  // REVIEW & SUBMIT
  // ============================================================

  Widget _buildReviewSubmit() {
    return Column(
      children: [
        _buildPetPreviewCard(),

        const SizedBox(height: 18),

        _buildReviewSection(
          title: 'Personal Information',
          icon: Icons.person_outline_rounded,
          items: [
            'Name: ${fullNameController.text}',
            'Phone: ${phoneController.text}',
            'Email: ${emailController.text}',
            'Age: ${ageController.text}',
            'Occupation: ${occupationController.text}',
          ],
        ),

        const SizedBox(height: 14),

        _buildReviewSection(
          title: 'Household Information',
          icon: Icons.home_outlined,
          items: [
            'Household: ${householdType ?? 'Not provided'}\nYard: ${yardAvailability ?? 'Not provided'}',
            'Address: ${addressController.text}',
            'Members: ${householdMembersController.text}',
            'Children: ${childrenController.text}',
          ],
        ),

        const SizedBox(height: 14),

        _buildReviewSection(
          title: 'Pet Experience',
          icon: Icons.pets_outlined,
          items: [
            'Experience: ${experienceLevel ?? 'Not provided'}',
            'Previous Pets: ${previousPetsController.text}',
            'Current Pets: ${currentPetsController.text}',
          ],
        ),

        const SizedBox(height: 14),

        _buildReviewSection(
          title: 'Lifestyle',
          icon: Icons.schedule_outlined,
          items: [
            'Home: ${homeEnvironment ?? 'Not provided'}',
            'Activity: ${activityLevel ?? 'Not provided'}',
            'Time Available: ${timeAvailableController.text}',
          ],
        ),

        const SizedBox(height: 14),

        _buildReviewSection(
          title: 'Adoption Reason',
          icon: Icons.favorite_border_rounded,
          items: [
            adoptionReasonController.text,
          ],
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: const Color(0xFFFFF5EA),
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE9C9AF),
            ),
          ),

          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 21,
                color: primaryColor,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Please review your information carefully before submitting your adoption application.',
                  style: TextStyle(
                    color: Color(0xFF6E5145),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            color: darkText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(13),
            border: Border.all(
              color: borderColor,
            ),
          ),

          child: TextField(
            key: ValueKey(label),
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,

            style: const TextStyle(
              color: darkText,
              fontSize: 14,
            ),

            decoration: InputDecoration(
              hintText: hint,

              hintStyle: const TextStyle(
                color: Color(0xFF9AA6AA),
                fontSize: 13,
              ),

              prefixIcon: icon != null
                  ? Icon(
                      icon,
                      color:
                          const Color(0xFF78888D),
                      size: 20,
                    )
                  : null,

              border: InputBorder.none,

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String? value,
    required String label,
    required String hint,
    required List<String> items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            color: darkText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          height: 54,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
          ),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(13),
            border: Border.all(
              color: borderColor,
            ),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: ValueKey(label),
              value: value,
              isExpanded: true,

              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: secondaryText,
                size: 22,
              ),

              hint: Text(
                hint,
                style: const TextStyle(
                  color: Color(0xFF9AA6AA),
                  fontSize: 13,
                ),
              ),

              style: const TextStyle(
                color: darkText,
                fontSize: 14,
              ),

              items: items.map(
                (item) {
                  return DropdownMenuItem<String>(
                    value: item,

                    child: Text(
                      item,
                      style:
                          const TextStyle(
                        color: darkText,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ).toList(),

              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 42,
            height: 42,

            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: primaryColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PET PREVIEW CARD
  // ============================================================

  Widget _buildPetPreviewCard() {
    final String image =
        widget.pet['image']?.toString() ?? '';

    final String name =
        widget.pet['name']?.toString() ?? 'Pet';

    final String breed =
        widget.pet['breed']?.toString() ?? '';

    final String age =
        widget.pet['age']?.toString() ?? '';

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Row(
        children: [
          // PET IMAGE
          ClipRRect(
            borderRadius:
                BorderRadius.circular(12),

            child: Image.network(
              image,

              width: 72,
              height: 72,

              fit: BoxFit.cover,

              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  width: 72,
                  height: 72,

                  color: lightBlue,

                  child: const Icon(
                    Icons.pets,
                    color: primaryColor,
                    size: 30,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 14),

          // INFORMATION
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Applying to adopt',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  name,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$breed • $age',
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.favorite_rounded,
            color: primaryColor,
            size: 23,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEW SECTION
  // ============================================================

  Widget _buildReviewSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: borderColor,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,

                decoration:
                    BoxDecoration(
                  color: lightPrimary,
                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ...items.map(
            (item) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 8,
                ),

                child: Text(
                  item.isEmpty
                      ? 'Not provided'
                      : item,

                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTON
  // ============================================================

  Widget _buildBottomButton() {
    final bool lastStep =
        currentStep == 5;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12,
      ),

      decoration: const BoxDecoration(
        color: backgroundColor,

        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Row(
          children: [
            // BACK
            if (currentStep > 0) ...[
              SizedBox(
                width: 100,
                height: 50,

                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (!_submitting) currentStep--;
                    });
                  },

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        primaryColor,

                    side: const BorderSide(
                      color: primaryColor,
                      width: 1.3,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        25,
                      ),
                    ),
                  ),

                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),
            ],

            // NEXT / SUBMIT
            Expanded(
              child: SizedBox(
                height: 50,

                child: ElevatedButton(
                  onPressed: _submitting ? null : _handleNext,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        25,
                      ),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      Flexible(
                        child: Text(
                          _submitting ? 'Submitting...' : lastStep
                              ? 'Submit Application'
                              : 'Next Step',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!lastStep) ...[
                        const SizedBox(width: 8),

                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 19,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NEXT BUTTON
  // ============================================================

  void _handleNext() {
    if (_submitting) return;
    if (!_validateCurrentStep()) {
      return;
    }

    if (currentStep < 5) {
      setState(() {
        currentStep++;
      });

      return;
    }

    _submitApplication();
  }

  // ============================================================
  // VALIDATE CURRENT STEP
  // ============================================================

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        final name = fullNameController.text.trim();
        final phone = phoneController.text.trim();
        final email = emailController.text.trim();
        final ageStr = ageController.text.trim();
        final occupation = occupationController.text.trim();

        if (name.isEmpty ||
            phone.isEmpty ||
            email.isEmpty ||
            ageStr.isEmpty ||
            occupation.isEmpty) {
          _showMessage(
            'Please complete all personal information.',
          );
          return false;
        }

        // Email validation
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(email)) {
          _showMessage(
            'Please enter a valid email address.',
          );
          return false;
        }

        // Phone validation (minimum 10 digits)
        final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
        if (cleanPhone.length < 10 || !RegExp(r'^\d+$').hasMatch(cleanPhone)) {
          _showMessage(
            'Please enter a valid contact number (e.g. 09123456789).',
          );
          return false;
        }

        // Age validation (18 - 100)
        final age = int.tryParse(ageStr);
        if (age == null || age < 18 || age > 100) {
          _showMessage(
            'Applicant must be at least 18 years old to adopt.',
          );
          return false;
        }

        return true;

      case 1:
        if (householdType == null || yardAvailability == null ||
            addressController.text
                .trim()
                .isEmpty ||
            householdMembersController
                .text
                .trim()
                .isEmpty ||
            childrenController.text
                .trim()
                .isEmpty) {
          _showMessage(
            'Please complete all household information.',
          );

          return false;
        }

        return true;

      case 2:
        if (experienceLevel == null ||
            previousPetsController.text
                .trim()
                .isEmpty ||
            currentPetsController.text
                .trim()
                .isEmpty) {
          _showMessage(
            'Please complete your pet experience information.',
          );

          return false;
        }

        return true;

      case 3:
        if (homeEnvironment == null ||
            activityLevel == null ||
            timeAvailableController.text
                .trim()
                .isEmpty) {
          _showMessage(
            'Please complete your lifestyle information.',
          );

          return false;
        }

        return true;

      case 4:
        if (adoptionReasonController.text
            .trim()
            .isEmpty) {
          _showMessage(
            'Please tell us why you want to adopt.',
          );

          return false;
        }

        if (!agreementAccepted) {
          _showMessage(
            'Please accept the adoption agreement.',
          );

          return false;
        }

        return true;

      case 5:
        return true;

      default:
        return false;
    }
  }


  bool _submitting = false;

  Future<void> _submitApplication() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    // ============================================================
    // SAVE APPLICATION
    // ============================================================

    try {
      await AdoptionApplicationStore.saveApplication(
      service: widget.adoptionService,
      pet: widget.pet,

      // PERSONAL INFORMATION
      fullName: fullNameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      age: ageController.text.trim(),
      occupation: occupationController.text.trim(),

      // HOUSEHOLD INFORMATION
      householdType: householdType ?? '',
      yardAvailability: yardAvailability ?? 'Not provided',
      address: addressController.text.trim(),
      householdMembers:
          householdMembersController.text.trim(),
      children:
          childrenController.text.trim(),

      // PET EXPERIENCE
      experienceLevel:
          experienceLevel ?? '',
      previousPets:
          previousPetsController.text.trim(),
      currentPets:
          currentPetsController.text.trim(),

      // LIFESTYLE
      homeEnvironment:
          homeEnvironment ?? '',
      activityLevel:
          activityLevel ?? '',
      timeAvailable:
          timeAvailableController.text.trim(),

      // ADOPTION
      adoptionReason:
          adoptionReasonController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final msg = e.toString().toLowerCase();
      _showMessage(
        msg.contains('uq_active_application') || msg.contains('duplicate')
            ? 'You already have an active application for this pet.'
            : msg.contains('logged in')
                ? 'Please log in to submit an adoption application.'
                : 'Could not submit your application. Please check your connection and try again.',
      );
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    // ============================================================
    // SUCCESS DIALOG
    // ============================================================

    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),

          contentPadding:
              const EdgeInsets.fromLTRB(
            24,
            28,
            24,
            20,
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                width: 70,
                height: 70,

                decoration:
                    const BoxDecoration(
                  color: lightBlue,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check_rounded,
                  color: primaryColor,
                  size: 38,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Application submitted',
                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Your adoption application for ${widget.pet['name']} has been submitted successfully. The shelter will review your application and contact you soon.',

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 48,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );

                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),
                    ),
                  ),

                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }









  // void _submitApplication() {
  //   // ============================================================
  //   // SAVE APPLICATION
  //   // ============================================================

  //   AdoptionApplicationStore.addApplication(
  //     pet: widget.pet,

  //     // PERSONAL INFORMATION
  //     fullName: fullNameController.text.trim(),
  //     phone: phoneController.text.trim(),
  //     email: emailController.text.trim(),
  //     age: ageController.text.trim(),
  //     occupation: occupationController.text.trim(),

  //     // HOUSEHOLD INFORMATION
  //     householdType: householdType ?? '',
  //     address: addressController.text.trim(),
  //     householdMembers:
  //         householdMembersController.text.trim(),
  //     children: childrenController.text.trim(),

  //     // PET EXPERIENCE
  //     experienceLevel: experienceLevel ?? '',
  //     previousPets: previousPetsController.text.trim(),
  //     currentPets: currentPetsController.text.trim(),

  //     // LIFESTYLE
  //     homeEnvironment: homeEnvironment ?? '',
  //     activityLevel: activityLevel ?? '',
  //     timeAvailable: timeAvailableController.text.trim(),

  //     // ADOPTION
  //     adoptionReason:
  //         adoptionReasonController.text.trim(),
  //   );

  //   // ============================================================
  //   // SUCCESS DIALOG
  //   // ============================================================

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,

  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,

  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),

  //         contentPadding:
  //             const EdgeInsets.fromLTRB(
  //           24,
  //           28,
  //           24,
  //           20,
  //         ),

  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,

  //           children: [
  //             Container(
  //               width: 70,
  //               height: 70,

  //               decoration:
  //                   const BoxDecoration(
  //                 color: lightBlue,
  //                 shape: BoxShape.circle,
  //               ),

  //               child: const Icon(
  //                 Icons.check_rounded,
  //                 color: primaryColor,
  //                 size: 38,
  //               ),
  //             ),

  //             const SizedBox(height: 18),

  //             const Text(
  //               'Application submitted',
  //               textAlign: TextAlign.center,

  //               style: TextStyle(
  //                 color: darkText,
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.w800,
  //               ),
  //             ),

  //             const SizedBox(height: 10),

  //             Text(
  //               'Your adoption application for '
  //               '${widget.pet['name']} has been '
  //               'submitted successfully. '
  //               'The shelter will review your '
  //               'application and contact you soon.',

  //               textAlign: TextAlign.center,

  //               style: const TextStyle(
  //                 color: secondaryText,
  //                 fontSize: 13,
  //                 height: 1.5,
  //               ),
  //             ),

  //             const SizedBox(height: 22),

  //             SizedBox(
  //               width: double.infinity,
  //               height: 48,

  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(
  //                     dialogContext,
  //                   );

  //                   Navigator.pop(
  //                     context,
  //                   );
  //                 },

  //                 style:
  //                     ElevatedButton.styleFrom(
  //                   backgroundColor:
  //                       primaryColor,

  //                   foregroundColor:
  //                       Colors.white,

  //                   elevation: 0,

  //                   shape:
  //                       RoundedRectangleBorder(
  //                     borderRadius:
  //                         BorderRadius.circular(
  //                       24,
  //                     ),
  //                   ),
  //                 ),

  //                 child: const Text(
  //                   'Done',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight:
  //                         FontWeight.w700,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }





  // ============================================================
  // SUBMIT APPLICATION
  // ============================================================

  // void _submitApplication() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,

  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,

  //         shape:
  //             RoundedRectangleBorder(
  //           borderRadius:
  //               BorderRadius.circular(16),
  //         ),

  //         contentPadding:
  //             const EdgeInsets.fromLTRB(
  //           24,
  //           28,
  //           24,
  //           20,
  //         ),

  //         content: Column(
  //           mainAxisSize:
  //               MainAxisSize.min,

  //           children: [
  //             Container(
  //               width: 70,
  //               height: 70,

  //               decoration:
  //                   const BoxDecoration(
  //                 color: lightBlue,
  //                 shape: BoxShape.circle,
  //               ),

  //               child: const Icon(
  //                 Icons.check_rounded,
  //                 color: primaryColor,
  //                 size: 38,
  //               ),
  //             ),

  //             const SizedBox(height: 18),

  //             const Text(
  //               'Application submitted',
  //               textAlign: TextAlign.center,

  //               style: TextStyle(
  //                 color: darkText,
  //                 fontSize: 20,
  //                 fontWeight:
  //                     FontWeight.w800,
  //               ),
  //             ),

  //             const SizedBox(height: 10),

  //             Text(
  //               'Your adoption application for ${widget.pet['name']} has been submitted successfully. The shelter will review your application and contact you soon.',

  //               textAlign:
  //                   TextAlign.center,

  //               style: const TextStyle(
  //                 color: secondaryText,
  //                 fontSize: 13,
  //                 height: 1.5,
  //               ),
  //             ),

  //             const SizedBox(height: 22),

  //             SizedBox(
  //               width: double.infinity,
  //               height: 48,

  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.pop(
  //                     dialogContext,
  //                   );

  //                   Navigator.pop(
  //                     context,
  //                   );
  //                 },

  //                 style:
  //                     ElevatedButton.styleFrom(
  //                   backgroundColor:
  //                       primaryColor,

  //                   foregroundColor:
  //                       Colors.white,

  //                   elevation: 0,

  //                   shape:
  //                       RoundedRectangleBorder(
  //                     borderRadius:
  //                         BorderRadius.circular(
  //                       24,
  //                     ),
  //                   ),
  //                 ),

  //                 child: const Text(
  //                   'Done',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight:
  //                         FontWeight.w700,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // ============================================================
  // EXIT CONFIRMATION
  // ============================================================

  void _confirmExit() {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),

          title: const Text(
            'Exit Application?',
            style: TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          content: const Text(
            'Your progress will not be saved if you exit this application.',
            style: TextStyle(
              color: secondaryText,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          actionsPadding:
              const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            14,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child: const Text(
                'Continue',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                Navigator.pop(
                  context,
                );
              },

              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),

        behavior:
            SnackBarBehavior.floating,

        margin: const EdgeInsets.all(16),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        duration:
            const Duration(seconds: 2),
      ),
    );
  }
}
