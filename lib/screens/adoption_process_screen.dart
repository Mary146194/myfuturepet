import 'package:flutter/material.dart';
import '../adoption_application_store.dart';

class AdoptionProcessScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  const AdoptionProcessScreen({
    super.key,
    required this.pet,
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
  static const Color cardColor = Colors.white;
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
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: _confirmExit,
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
            fontSize: 17,
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
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: lightPrimary,
                      borderRadius:
                          BorderRadius.circular(20),
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
                  right: index == 5 ? 0 : 5,
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
              padding: EdgeInsets.only(top: 3),

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
            'Household: ${householdType ?? 'Not provided'}',
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

        const SizedBox(height: 7),

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

        const SizedBox(height: 7),

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

                const SizedBox(height: 5),

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
                  (_, __, ___) {
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
                    fontSize: 19,
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
                    fontSize: 15,
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
            blurRadius: 12,
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
                      currentStep--;
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
                  onPressed: _handleNext,

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
                      Text(
                        lastStep
                            ? 'Submit Application'
                            : 'Next Step',
                        style:
                            const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
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
        if (fullNameController.text
                .trim()
                .isEmpty ||
            phoneController.text
                .trim()
                .isEmpty ||
            emailController.text
                .trim()
                .isEmpty ||
            ageController.text
                .trim()
                .isEmpty ||
            occupationController.text
                .trim()
                .isEmpty) {
          _showMessage(
            'Please complete all personal information.',
          );

          return false;
        }

        return true;

      case 1:
        if (householdType == null ||
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


  void _submitApplication() {
    // ============================================================
    // SAVE APPLICATION
    // ============================================================

    AdoptionApplicationStore.saveApplication(
      pet: widget.pet,

      // PERSONAL INFORMATION
      fullName: fullNameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      age: ageController.text.trim(),
      occupation: occupationController.text.trim(),

      // HOUSEHOLD INFORMATION
      householdType: householdType ?? '',
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
                BorderRadius.circular(22),
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
                'Application Submitted!',
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
  //           borderRadius: BorderRadius.circular(22),
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
  //               'Application Submitted!',
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
  //               BorderRadius.circular(22),
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
  //               'Application Submitted!',
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
                BorderRadius.circular(20),
          ),

          title: const Text(
            'Exit Application?',
            style: TextStyle(
              color: darkText,
              fontSize: 19,
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



















// import 'package:flutter/material.dart';

// class AdoptionProcessScreen extends StatefulWidget {
//   final Map<String, dynamic> pet;

//   const AdoptionProcessScreen({
//     super.key,
//     required this.pet,
//   });

//   @override
//   State<AdoptionProcessScreen> createState() =>
//       _AdoptionProcessScreenState();
// }

// class _AdoptionProcessScreenState
//     extends State<AdoptionProcessScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor =
//       Color(0xFFA94327);

//   static const Color darkText =
//       Color(0xFF062B35);

//   static const Color backgroundColor =
//       Color(0xFFEFF9FD);

//   static const Color borderColor =
//       Color(0xFFB8C5CA);

//   static const Color secondaryText =
//       Color(0xFF68777C);

//   // ============================================================
//   // CURRENT STEP
//   // ============================================================

//   int currentStep = 0;

//   // ============================================================
//   // FORM CONTROLLERS
//   // ============================================================

//   // STEP 1
//   final TextEditingController fullNameController =
//       TextEditingController();

//   final TextEditingController phoneController =
//       TextEditingController();

//   final TextEditingController emailController =
//       TextEditingController();

//   final TextEditingController ageController =
//       TextEditingController();

//   final TextEditingController occupationController =
//       TextEditingController();

//   // STEP 2
//   final TextEditingController addressController =
//       TextEditingController();

//   final TextEditingController householdMembersController =
//       TextEditingController();

//   final TextEditingController childrenController =
//       TextEditingController();

//   // STEP 3
//   final TextEditingController previousPetsController =
//       TextEditingController();

//   final TextEditingController currentPetsController =
//       TextEditingController();

//   // STEP 4
//   final TextEditingController timeAvailableController =
//       TextEditingController();

//   // STEP 5
//   final TextEditingController adoptionReasonController =
//       TextEditingController();

//   // ============================================================
//   // DROPDOWN VALUES
//   // ============================================================

//   String? householdType;
//   String? experienceLevel;
//   String? homeEnvironment;
//   String? activityLevel;

//   bool agreementAccepted = false;

//   // ============================================================
//   // STEP TITLES
//   // ============================================================

//   final List<String> stepTitles = [
//     'Personal Information',
//     'Household Information',
//     'Pet Experience',
//     'Lifestyle & Preferences',
//     'Adoption Preferences',
//     'Review & Submit',
//   ];

//   // ============================================================
//   // DISPOSE
//   // ============================================================

//   @override
//   void dispose() {
//     fullNameController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     ageController.dispose();
//     occupationController.dispose();

//     addressController.dispose();
//     householdMembersController.dispose();
//     childrenController.dispose();

//     previousPetsController.dispose();
//     currentPetsController.dispose();

//     timeAvailableController.dispose();

//     adoptionReasonController.dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,

//       child: SafeArea(
//         child: Container(
//           color: backgroundColor,

//           child: Column(
//             children: [
//               // ==================================================
//               // TOP BAR
//               // ==================================================

//               _buildTopBar(),

//               // ==================================================
//               // PROGRESS
//               // ==================================================

//               _buildProgress(),

//               // ==================================================
//               // CONTENT
//               // ==================================================

//               Expanded(
//                 child: SingleChildScrollView(
//                   physics:
//                       const BouncingScrollPhysics(),

//                   padding:
//                       const EdgeInsets.fromLTRB(
//                     12,
//                     8,
//                     12,
//                     20,
//                   ),

//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start,

//                     children: [
//                       // STEP LABEL
//                       Text(
//                         'STEP ${currentStep + 1} OF 6',

//                         style:
//                             const TextStyle(
//                           color: primaryColor,
//                           fontSize: 7,
//                           fontWeight:
//                               FontWeight.bold,
//                           letterSpacing: 0.3,
//                         ),
//                       ),

//                       const SizedBox(height: 7),

//                       // STEP TITLE
//                       Text(
//                         stepTitles[currentStep],

//                         style:
//                             const TextStyle(
//                           color: darkText,
//                           fontSize: 17,
//                           fontWeight:
//                               FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 6),

//                       // STEP DESCRIPTION
//                       Text(
//                         _getStepDescription(),

//                         style:
//                             const TextStyle(
//                           color:
//                               secondaryText,
//                           fontSize: 8,
//                           height: 1.35,
//                         ),
//                       ),

//                       const SizedBox(height: 14),

//                       // STEP CONTENT
//                       _buildCurrentStep(),
//                     ],
//                   ),
//                 ),
//               ),

//               // ==================================================
//               // BOTTOM BUTTON
//               // ==================================================

//               _buildBottomButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // TOP BAR
//   // ============================================================

//   Widget _buildTopBar() {
//     return Container(
//       height: 38,

//       decoration:
//           const BoxDecoration(
//         color: backgroundColor,

//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFD9E4E8),
//             width: 1,
//           ),
//         ),
//       ),

//       child: Row(
//         children: [
//           // CLOSE BUTTON
//           SizedBox(
//             width: 40,

//             child: IconButton(
//               padding: EdgeInsets.zero,

//               icon: const Icon(
//                 Icons.close_rounded,
//                 size: 15,
//                 color: darkText,
//               ),

//               onPressed: () {
//                 _confirmExit();
//               },
//             ),
//           ),

//           // TITLE
//           const Expanded(
//             child: Center(
//               child: Text(
//                 'Application',
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 9,
//                   fontWeight:
//                       FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),

//           // EMPTY SPACE
//           const SizedBox(width: 40),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PROGRESS BAR
//   // ============================================================

//   Widget _buildProgress() {
//     return Padding(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 8,
//       ),

//       child: Row(
//         children: List.generate(
//           6,
//           (index) {
//             final bool completed =
//                 index <= currentStep;

//             return Expanded(
//               child: Container(
//                 height: 3,

//                 margin:
//                     EdgeInsets.only(
//                   right:
//                       index == 5 ? 0 : 3,
//                 ),

//                 decoration:
//                     BoxDecoration(
//                   color: completed
//                       ? primaryColor
//                       : const Color(
//                           0xFFD5E2E6,
//                         ),

//                   borderRadius:
//                       BorderRadius.circular(
//                     5,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // STEP DESCRIPTION
//   // ============================================================

//   String _getStepDescription() {
//     switch (currentStep) {
//       case 0:
//         return 'Let’s start with the basics to help us match you with your perfect companion.';

//       case 1:
//         return 'Tell us about your home and the people or pets who will be living with your new companion.';

//       case 2:
//         return 'Help us understand your experience caring for pets.';

//       case 3:
//         return 'Tell us about your daily routine and the environment your pet will live in.';

//       case 4:
//         return 'Tell us why you want to adopt and what you expect from the adoption process.';

//       case 5:
//         return 'Review your application and confirm that the information you provided is correct.';

//       default:
//         return '';
//     }
//   }

//   // ============================================================
//   // CURRENT STEP
//   // ============================================================

//   Widget _buildCurrentStep() {
//     switch (currentStep) {
//       case 0:
//         return _buildPersonalInformation();

//       case 1:
//         return _buildHouseholdInformation();

//       case 2:
//         return _buildPetExperience();

//       case 3:
//         return _buildLifestylePreferences();

//       case 4:
//         return _buildAdoptionPreferences();

//       case 5:
//         return _buildReviewSubmit();

//       default:
//         return const SizedBox();
//     }
//   }

//   // ============================================================
//   // STEP 1
//   // PERSONAL INFORMATION
//   // ============================================================

//   Widget _buildPersonalInformation() {
//     return Column(
//       children: [
//         _buildTextField(
//           controller: fullNameController,
//           hint: 'Full Name',
//           icon: Icons.person_outline_rounded,
//         ),

//         const SizedBox(height: 10),

//         _buildTextField(
//           controller: phoneController,
//           hint: 'Phone Number',
//           keyboardType:
//               TextInputType.phone,
//           icon: Icons.phone_outlined,
//         ),

//         const SizedBox(height: 10),

//         _buildTextField(
//           controller: emailController,
//           hint: 'Email Address',
//           keyboardType:
//               TextInputType.emailAddress,
//           icon: Icons.email_outlined,
//         ),

//         const SizedBox(height: 10),

//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 controller: ageController,
//                 hint: 'Age',
//                 keyboardType:
//                     TextInputType.number,
//                 icon: Icons.cake_outlined,
//               ),
//             ),

//             const SizedBox(width: 8),

//             Expanded(
//               child: _buildTextField(
//                 controller:
//                     occupationController,
//                 hint: 'Occupation',
//                 icon:
//                     Icons.work_outline_rounded,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // STEP 2
//   // HOUSEHOLD INFORMATION
//   // ============================================================

//   Widget _buildHouseholdInformation() {
//     return Column(
//       children: [
//         _buildDropdown(
//           value: householdType,
//           hint: 'Household Type',
//           items: const [
//             'House',
//             'Apartment',
//             'Condominium',
//             'Townhouse',
//             'Other',
//           ],
//           onChanged: (value) {
//             setState(() {
//               householdType = value;
//             });
//           },
//         ),

//         const SizedBox(height: 10),

//         _buildTextField(
//           controller: addressController,
//           hint: 'Complete Address',
//           icon:
//               Icons.location_on_outlined,
//         ),

//         const SizedBox(height: 10),

//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 controller:
//                     householdMembersController,
//                 hint: 'Household Members',
//                 keyboardType:
//                     TextInputType.number,
//                 icon:
//                     Icons.people_outline_rounded,
//               ),
//             ),

//             const SizedBox(width: 8),

//             Expanded(
//               child: _buildTextField(
//                 controller:
//                     childrenController,
//                 hint: 'Children',
//                 keyboardType:
//                     TextInputType.number,
//                 icon:
//                     Icons.child_friendly_outlined,
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 12),

//         _buildInfoCard(
//           icon:
//               Icons.home_outlined,
//           title: 'Home Environment',
//           description:
//               'Please provide accurate information about where your adopted pet will stay.',
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // STEP 3
//   // PET EXPERIENCE
//   // ============================================================

//   Widget _buildPetExperience() {
//     return Column(
//       children: [
//         _buildDropdown(
//           value: experienceLevel,
//           hint: 'Pet Experience Level',
//           items: const [
//             'First-time pet owner',
//             'Some experience',
//             'Experienced pet owner',
//             'Very experienced',
//           ],
//           onChanged: (value) {
//             setState(() {
//               experienceLevel = value;
//             });
//           },
//         ),

//         const SizedBox(height: 10),

//         _buildTextField(
//           controller:
//               previousPetsController,
//           hint: 'Previous Pets',
//           maxLines: 3,
//           icon: Icons.pets_outlined,
//         ),

//         const SizedBox(height: 10),

//         _buildTextField(
//           controller:
//               currentPetsController,
//           hint: 'Current Pets',
//           maxLines: 3,
//           icon:
//               Icons.cruelty_free_outlined,
//         ),

//         const SizedBox(height: 12),

//         _buildInfoCard(
//           icon: Icons.favorite_outline,
//           title: 'Pet Care Experience',
//           description:
//               'Tell us about your previous or current experience caring for animals.',
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // STEP 4
//   // LIFESTYLE & PREFERENCES
//   // ============================================================

//   Widget _buildLifestylePreferences() {
//     return Column(
//       children: [
//         _buildDropdown(
//           value: homeEnvironment,
//           hint: 'Home Environment',
//           items: const [
//             'Quiet',
//             'Moderately Active',
//             'Very Active',
//           ],
//           onChanged: (value) {
//             setState(() {
//               homeEnvironment = value;
//             });
//           },
//         ),

//         const SizedBox(height: 10),

//         _buildDropdown(
//           value: activityLevel,
//           hint: 'Activity Level',
//           items: const [
//             'Low',
//             'Moderate',
//             'High',
//           ],
//           onChanged: (value) {
//             setState(() {
//               activityLevel = value;
//             });
//           },
//         ),

//         const SizedBox(height: 10),

//         _buildTextField(
//           controller:
//               timeAvailableController,
//           hint:
//               'How much time can you spend with your pet each day?',
//           maxLines: 3,
//           icon:
//               Icons.access_time_outlined,
//         ),

//         const SizedBox(height: 12),

//         _buildInfoCard(
//           icon:
//               Icons.schedule_outlined,
//           title: 'Daily Routine',
//           description:
//               'Consider feeding, exercise, training, grooming, and companionship.',
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // STEP 5
//   // ADOPTION PREFERENCES
//   // ============================================================

//   Widget _buildAdoptionPreferences() {
//     return Column(
//       children: [
//         _buildPetPreviewCard(),

//         const SizedBox(height: 12),

//         _buildTextField(
//           controller:
//               adoptionReasonController,
//           hint:
//               'Why do you want to adopt this pet?',
//           maxLines: 5,
//           icon:
//               Icons.favorite_border_rounded,
//         ),

//         const SizedBox(height: 12),

//         Container(
//           padding:
//               const EdgeInsets.all(10),

//           decoration: BoxDecoration(
//             color: Colors.white,

//             borderRadius:
//                 BorderRadius.circular(8),

//             border: Border.all(
//               color: borderColor,
//             ),
//           ),

//           child: Row(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,

//             children: [
//               Checkbox(
//                 value:
//                     agreementAccepted,

//                 activeColor:
//                     primaryColor,

//                 visualDensity:
//                     VisualDensity.compact,

//                 onChanged: (value) {
//                   setState(() {
//                     agreementAccepted =
//                         value ?? false;
//                   });
//                 },
//               ),

//               const Expanded(
//                 child: Padding(
//                   padding:
//                       EdgeInsets.only(
//                     top: 5,
//                   ),

//                   child: Text(
//                     'I understand that adopting a pet is a long-term responsibility and I agree to provide proper care, food, shelter, veterinary care, and a safe environment.',
//                     style: TextStyle(
//                       color:
//                           secondaryText,
//                       fontSize: 8,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // STEP 6
//   // REVIEW & SUBMIT
//   // ============================================================

//   Widget _buildReviewSubmit() {
//     return Column(
//       children: [
//         _buildPetPreviewCard(),

//         const SizedBox(height: 12),

//         _buildReviewSection(
//           title: 'Personal Information',
//           items: [
//             'Name: ${fullNameController.text}',
//             'Phone: ${phoneController.text}',
//             'Email: ${emailController.text}',
//             'Age: ${ageController.text}',
//             'Occupation: ${occupationController.text}',
//           ],
//         ),

//         const SizedBox(height: 10),

//         _buildReviewSection(
//           title: 'Household Information',
//           items: [
//             'Household: ${householdType ?? 'Not provided'}',
//             'Address: ${addressController.text}',
//             'Members: ${householdMembersController.text}',
//             'Children: ${childrenController.text}',
//           ],
//         ),

//         const SizedBox(height: 10),

//         _buildReviewSection(
//           title: 'Pet Experience',
//           items: [
//             'Experience: ${experienceLevel ?? 'Not provided'}',
//             'Previous Pets: ${previousPetsController.text}',
//             'Current Pets: ${currentPetsController.text}',
//           ],
//         ),

//         const SizedBox(height: 10),

//         _buildReviewSection(
//           title: 'Lifestyle',
//           items: [
//             'Home: ${homeEnvironment ?? 'Not provided'}',
//             'Activity: ${activityLevel ?? 'Not provided'}',
//             'Time Available: ${timeAvailableController.text}',
//           ],
//         ),

//         const SizedBox(height: 10),

//         _buildReviewSection(
//           title: 'Adoption Reason',
//           items: [
//             adoptionReasonController.text,
//           ],
//         ),

//         const SizedBox(height: 12),

//         Container(
//           width: double.infinity,

//           padding:
//               const EdgeInsets.all(12),

//           decoration: BoxDecoration(
//             color:
//                 const Color(0xFFFFF3E8),

//             borderRadius:
//                 BorderRadius.circular(9),

//             border: Border.all(
//               color:
//                   const Color(0xFFE9C9AF),
//             ),
//           ),

//           child: const Row(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,

//             children: [
//               Icon(
//                 Icons.info_outline_rounded,
//                 size: 16,
//                 color: primaryColor,
//               ),

//               SizedBox(width: 7),

//               Expanded(
//                 child: Text(
//                   'Please review your information carefully before submitting your adoption application.',
//                   style: TextStyle(
//                     color:
//                         Color(0xFF6E5145),
//                     fontSize: 8,
//                     height: 1.4,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // TEXT FIELD
//   // ============================================================

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     IconData? icon,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,

//         border: Border.all(
//           color: borderColor,
//           width: 1,
//         ),
//       ),

//       child: TextField(
//         controller: controller,

//         keyboardType: keyboardType,

//         maxLines: maxLines,

//         style: const TextStyle(
//           color: darkText,
//           fontSize: 9,
//         ),

//         decoration:
//             InputDecoration(
//           hintText: hint,

//           hintStyle:
//               const TextStyle(
//             color:
//                 Color(0xFF7C8588),
//             fontSize: 8,
//           ),

//           prefixIcon: icon != null
//               ? Icon(
//                   icon,
//                   size: 14,
//                   color:
//                       const Color(
//                     0xFF78888D,
//                   ),
//                 )
//               : null,

//           prefixIconConstraints:
//               const BoxConstraints(
//             minWidth: 32,
//           ),

//           border:
//               InputBorder.none,

//           contentPadding:
//               const EdgeInsets
//                   .symmetric(
//             horizontal: 9,
//             vertical: 9,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DROPDOWN
//   // ============================================================

//   Widget _buildDropdown({
//     required String? value,
//     required String hint,
//     required List<String> items,
//     required ValueChanged<String?>
//         onChanged,
//   }) {
//     return Container(
//       height: 38,

//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 9,
//       ),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         border: Border.all(
//           color: borderColor,
//           width: 1,
//         ),
//       ),

//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,

//           isExpanded: true,

//           icon: const Icon(
//             Icons.keyboard_arrow_down_rounded,
//             size: 16,
//             color: Color(0xFF68777C),
//           ),

//           hint: Text(
//             hint,
//             style: const TextStyle(
//               color:
//                   Color(0xFF7C8588),
//               fontSize: 8,
//             ),
//           ),

//           style: const TextStyle(
//             color: darkText,
//             fontSize: 9,
//           ),

//           items:
//               items.map(
//             (item) {
//               return DropdownMenuItem<
//                   String>(
//                 value: item,

//                 child: Text(
//                   item,
//                   style:
//                       const TextStyle(
//                     color:
//                         darkText,
//                     fontSize: 9,
//                   ),
//                 ),
//               );
//             },
//           ).toList(),

//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // INFO CARD
//   // ============================================================

//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String description,
//   }) {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(10),

//       decoration: BoxDecoration(
//         color:
//             const Color(0xFFE4F5FB),

//         borderRadius:
//             BorderRadius.circular(8),
//       ),

//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Container(
//             width: 28,
//             height: 28,

//             decoration:
//                 const BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//             ),

//             child: Icon(
//               icon,
//               size: 14,
//               color: primaryColor,
//             ),
//           ),

//           const SizedBox(width: 8),

//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [
//                 Text(
//                   title,

//                   style:
//                       const TextStyle(
//                     color: darkText,
//                     fontSize: 9,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 3),

//                 Text(
//                   description,

//                   style:
//                       const TextStyle(
//                     color:
//                         secondaryText,
//                     fontSize: 7.5,
//                     height: 1.35,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PET PREVIEW CARD
//   // ============================================================

//   Widget _buildPetPreviewCard() {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(8),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(9),

//         border: Border.all(
//           color: borderColor,
//         ),
//       ),

//       child: Row(
//         children: [
//           // PET IMAGE
//           ClipRRect(
//             borderRadius:
//                 BorderRadius.circular(7),

//             child: Image.network(
//               widget.pet['image'].toString(),

//               width: 48,
//               height: 48,

//               fit: BoxFit.cover,

//               errorBuilder:
//                   (_, __, ___) {
//                 return Container(
//                   width: 48,
//                   height: 48,

//                   color:
//                       const Color(
//                     0xFFE9EEF0,
//                   ),

//                   child: const Icon(
//                     Icons.pets,
//                     color:
//                         primaryColor,
//                     size: 20,
//                   ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(width: 9),

//           // PET INFORMATION
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [
//                 Text(
//                   'Applying to adopt',

//                   style:
//                       const TextStyle(
//                     color:
//                         secondaryText,
//                     fontSize: 7,
//                   ),
//                 ),

//                 const SizedBox(height: 2),

//                 Text(
//                   widget.pet['name']
//                       .toString(),

//                   style:
//                       const TextStyle(
//                     color: darkText,
//                     fontSize: 13,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 2),

//                 Text(
//                   '${widget.pet['breed']} • ${widget.pet['age']}',

//                   style:
//                       const TextStyle(
//                     color:
//                         secondaryText,
//                     fontSize: 7.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const Icon(
//             Icons.favorite_rounded,
//             color: primaryColor,
//             size: 17,
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // REVIEW SECTION
//   // ============================================================

//   Widget _buildReviewSection({
//     required String title,
//     required List<String> items,
//   }) {
//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.all(10),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(8),

//         border: Border.all(
//           color: borderColor,
//         ),
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Text(
//             title,

//             style:
//                 const TextStyle(
//               color: darkText,
//               fontSize: 9,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 7),

//           ...items.map(
//             (item) {
//               return Padding(
//                 padding:
//                     const EdgeInsets.only(
//                   bottom: 4,
//                 ),

//                 child: Text(
//                   item.isEmpty
//                       ? 'Not provided'
//                       : item,

//                   style:
//                       const TextStyle(
//                     color:
//                         secondaryText,
//                     fontSize: 7.5,
//                     height: 1.3,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // BOTTOM BUTTON
//   // ============================================================

//   Widget _buildBottomButton() {
//     final bool lastStep =
//         currentStep == 5;

//     return Container(
//       padding:
//           const EdgeInsets.fromLTRB(
//         12,
//         8,
//         12,
//         8,
//       ),

//       decoration:
//           const BoxDecoration(
//         color: backgroundColor,

//         boxShadow: [
//           BoxShadow(
//             color: Color(0x18000000),
//             blurRadius: 7,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),

//       child: SafeArea(
//         top: false,

//         child: Row(
//           children: [
//             // BACK BUTTON
//             if (currentStep > 0)
//               SizedBox(
//                 width: 80,
//                 height: 38,

//                 child: OutlinedButton(
//                   onPressed: () {
//                     setState(() {
//                       currentStep--;
//                     });
//                   },

//                   style:
//                       OutlinedButton.styleFrom(
//                     foregroundColor:
//                         primaryColor,

//                     side:
//                         const BorderSide(
//                       color:
//                           primaryColor,
//                     ),

//                     shape:
//                         RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(
//                         22,
//                       ),
//                     ),

//                     padding:
//                         EdgeInsets.zero,
//                   ),

//                   child:
//                       const Text(
//                     'Back',
//                     style:
//                         TextStyle(
//                       fontSize: 9,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),

//             if (currentStep > 0)
//               const SizedBox(width: 7),

//             // NEXT / SUBMIT BUTTON
//             Expanded(
//               child: SizedBox(
//                 height: 38,

//                 child:
//                     ElevatedButton(
//                   onPressed:
//                       _handleNext,

//                   style:
//                       ElevatedButton
//                           .styleFrom(
//                     backgroundColor:
//                         primaryColor,

//                     foregroundColor:
//                         Colors.white,

//                     elevation: 0,

//                     shape:
//                         RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(
//                         22,
//                       ),
//                     ),
//                   ),

//                   child: Text(
//                     lastStep
//                         ? 'Submit Application'
//                         : 'Next Step →',

//                     style:
//                         const TextStyle(
//                       fontSize: 9,
//                       fontWeight:
//                           FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // NEXT BUTTON
//   // ============================================================

//   void _handleNext() {
//     if (!_validateCurrentStep()) {
//       return;
//     }

//     if (currentStep < 5) {
//       setState(() {
//         currentStep++;
//       });

//       return;
//     }

//     // ========================================================
//     // SUBMIT
//     // ========================================================

//     _submitApplication();
//   }

//   // ============================================================
//   // VALIDATE CURRENT STEP
//   // ============================================================

//   bool _validateCurrentStep() {
//     switch (currentStep) {
//       case 0:
//         if (fullNameController.text.trim().isEmpty ||
//             phoneController.text.trim().isEmpty ||
//             emailController.text.trim().isEmpty ||
//             ageController.text.trim().isEmpty ||
//             occupationController.text.trim().isEmpty) {
//           _showMessage(
//             'Please complete all personal information.',
//           );

//           return false;
//         }

//         return true;

//       case 1:
//         if (householdType == null ||
//             addressController.text.trim().isEmpty ||
//             householdMembersController
//                 .text
//                 .trim()
//                 .isEmpty ||
//             childrenController.text
//                 .trim()
//                 .isEmpty) {
//           _showMessage(
//             'Please complete all household information.',
//           );

//           return false;
//         }

//         return true;

//       case 2:
//         if (experienceLevel == null ||
//             previousPetsController.text
//                 .trim()
//                 .isEmpty ||
//             currentPetsController.text
//                 .trim()
//                 .isEmpty) {
//           _showMessage(
//             'Please complete your pet experience information.',
//           );

//           return false;
//         }

//         return true;

//       case 3:
//         if (homeEnvironment == null ||
//             activityLevel == null ||
//             timeAvailableController.text
//                 .trim()
//                 .isEmpty) {
//           _showMessage(
//             'Please complete your lifestyle information.',
//           );

//           return false;
//         }

//         return true;

//       case 4:
//         if (adoptionReasonController.text
//             .trim()
//             .isEmpty) {
//           _showMessage(
//             'Please tell us why you want to adopt.',
//           );

//           return false;
//         }

//         if (!agreementAccepted) {
//           _showMessage(
//             'Please accept the adoption agreement.',
//           );

//           return false;
//         }

//         return true;

//       case 5:
//         return true;

//       default:
//         return false;
//     }
//   }

//   // ============================================================
//   // SUBMIT APPLICATION
//   // ============================================================

//   void _submitApplication() {
//     showDialog(
//       context: context,

//       barrierDismissible: false,

//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor:
//               backgroundColor,

//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(
//               18,
//             ),
//           ),

//           content: Column(
//             mainAxisSize:
//                 MainAxisSize.min,

//             children: [
//               Container(
//                 width: 58,
//                 height: 58,

//                 decoration:
//                     const BoxDecoration(
//                   color:
//                       Color(0xFFE4F5FB),
//                   shape: BoxShape.circle,
//                 ),

//                 child: const Icon(
//                   Icons.check_rounded,
//                   color:
//                       primaryColor,
//                   size: 32,
//                 ),
//               ),

//               const SizedBox(height: 14),

//               const Text(
//                 'Application Submitted!',

//                 textAlign:
//                     TextAlign.center,

//                 style:
//                     TextStyle(
//                   color: darkText,
//                   fontSize: 17,
//                   fontWeight:
//                       FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 7),

//               Text(
//                 'Your adoption application for ${widget.pet['name']} has been submitted successfully. The shelter will review your application and contact you soon.',

//                 textAlign:
//                     TextAlign.center,

//                 style:
//                     const TextStyle(
//                   color:
//                       secondaryText,
//                   fontSize: 9,
//                   height: 1.4,
//                 ),
//               ),

//               const SizedBox(height: 18),

//               SizedBox(
//                 width: double.infinity,
//                 height: 38,

//                 child:
//                     ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(
//                       dialogContext,
//                     );

//                     Navigator.pop(
//                       context,
//                     );
//                   },

//                   style:
//                       ElevatedButton
//                           .styleFrom(
//                     backgroundColor:
//                         primaryColor,

//                     foregroundColor:
//                         Colors.white,

//                     elevation: 0,

//                     shape:
//                         RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(
//                         20,
//                       ),
//                     ),
//                   ),

//                   child:
//                       const Text(
//                     'Done',
//                     style:
//                         TextStyle(
//                       fontSize: 9,
//                       fontWeight:
//                           FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // EXIT CONFIRMATION
//   // ============================================================

//   void _confirmExit() {
//     showDialog(
//       context: context,

//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor:
//               backgroundColor,

//           title: const Text(
//             'Exit Application?',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 17,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           content: const Text(
//             'Your progress will not be saved if you exit this application.',
//             style: TextStyle(
//               color: secondaryText,
//               fontSize: 9,
//               height: 1.4,
//             ),
//           ),

//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                 );
//               },

//               child:
//                   const Text(
//                 'Continue',
//                 style:
//                     TextStyle(
//                   color: primaryColor,
//                   fontSize: 9,
//                   fontWeight:
//                       FontWeight.w600,
//                 ),
//               ),
//             ),

//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                 );

//                 Navigator.pop(
//                   context,
//                 );
//               },

//               child:
//                   const Text(
//                 'Exit',
//                 style:
//                     TextStyle(
//                   color: Color(0xFF777777),
//                   fontSize: 9,
//                   fontWeight:
//                       FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style:
//               const TextStyle(
//             fontSize: 11,
//           ),
//         ),

//         behavior:
//             SnackBarBehavior.floating,

//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }
















// import 'package:flutter/material.dart';

// class AdoptionProcessScreen extends StatefulWidget {
//   final Map<String, dynamic> pet;

//   const AdoptionProcessScreen({
//     super.key,
//     required this.pet,
//   });

//   @override
//   State<AdoptionProcessScreen> createState() =>
//       _AdoptionProcessScreenState();
// }

// class _AdoptionProcessScreenState
//     extends State<AdoptionProcessScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor = Color(0xFFA94327);
//   static const Color darkText = Color(0xFF062B35);
//   static const Color backgroundColor = Color(0xFFF5FAFD);
//   static const Color fieldBorder = Color(0xFFB7C2C7);
//   static const Color subtitleColor = Color(0xFF68777C);

//   // ============================================================
//   // CONTROLLERS
//   // ============================================================

//   final TextEditingController _fullNameController =
//       TextEditingController();

//   final TextEditingController _phoneController =
//       TextEditingController();

//   final TextEditingController _emailController =
//       TextEditingController();

//   final TextEditingController _ageController =
//       TextEditingController();

//   final TextEditingController _occupationController =
//       TextEditingController();

//   // ============================================================
//   // LIFECYCLE
//   // ============================================================

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _ageController.dispose();
//     _occupationController.dispose();

//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       body: SafeArea(
//         child: Column(
//           children: [
//             // ====================================================
//             // TOP BAR
//             // ====================================================

//             _buildTopBar(),

//             // ====================================================
//             // CONTENT
//             // ====================================================

//             Expanded(
//               child: SingleChildScrollView(
//                 physics:
//                     const BouncingScrollPhysics(),

//                 padding: const EdgeInsets.fromLTRB(
//                   12,
//                   12,
//                   12,
//                   100,
//                 ),

//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,

//                   children: [
//                     // ==================================================
//                     // STEP
//                     // ==================================================

//                     const Text(
//                       'STEP 1 OF 6',
//                       style: TextStyle(
//                         color: primaryColor,
//                         fontSize: 7,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                     ),

//                     const SizedBox(height: 7),

//                     // ==================================================
//                     // TITLE
//                     // ==================================================

//                     const Text(
//                       'Personal Information',
//                       style: TextStyle(
//                         color: darkText,
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 5),

//                     // ==================================================
//                     // DESCRIPTION
//                     // ==================================================

//                     const Text(
//                       "Let's start with the basics to help us match you with\nyour perfect companion.",
//                       style: TextStyle(
//                         color: subtitleColor,
//                         fontSize: 7.5,
//                         height: 1.45,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     // ==================================================
//                     // PROGRESS BAR
//                     // ==================================================

//                     _buildProgressBar(),

//                     const SizedBox(height: 12),

//                     // ==================================================
//                     // FULL NAME
//                     // ==================================================

//                     _buildTextField(
//                       controller: _fullNameController,
//                       hintText: 'Full Name',
//                       keyboardType:
//                           TextInputType.name,
//                     ),

//                     const SizedBox(height: 10),

//                     // ==================================================
//                     // PHONE NUMBER
//                     // ==================================================

//                     _buildTextField(
//                       controller: _phoneController,
//                       hintText: 'Phone Number',
//                       keyboardType:
//                           TextInputType.phone,
//                     ),

//                     const SizedBox(height: 10),

//                     // ==================================================
//                     // EMAIL
//                     // ==================================================

//                     _buildTextField(
//                       controller: _emailController,
//                       hintText: 'Email Address',
//                       keyboardType:
//                           TextInputType.emailAddress,
//                     ),

//                     const SizedBox(height: 10),

//                     // ==================================================
//                     // AGE + OCCUPATION
//                     // ==================================================

//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildTextField(
//                             controller:
//                                 _ageController,
//                             hintText: 'Age',
//                             keyboardType:
//                                 TextInputType.number,
//                           ),
//                         ),

//                         const SizedBox(width: 8),

//                         Expanded(
//                           child: _buildTextField(
//                             controller:
//                                 _occupationController,
//                             hintText: 'Occupation',
//                             keyboardType:
//                                 TextInputType.text,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ========================================================
//             // BOTTOM NEXT BUTTON
//             // ========================================================

//             _buildBottomButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // TOP BAR
//   // ============================================================

//   Widget _buildTopBar() {
//     return SizedBox(
//       height: 38,

//       child: Stack(
//         alignment: Alignment.center,

//         children: [
//           // ==================================================
//           // CLOSE BUTTON
//           // ==================================================

//           Positioned(
//             left: 12,

//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },

//               child: const SizedBox(
//                 width: 25,
//                 height: 25,

//                 child: Align(
//                   alignment: Alignment.centerLeft,

//                   child: Text(
//                     '×',
//                     style: TextStyle(
//                       color: darkText,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // ==================================================
//           // TITLE
//           // ==================================================

//           const Text(
//             'Application',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 8,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PROGRESS BAR
//   // ============================================================

//   Widget _buildProgressBar() {
//     return Container(
//       width: double.infinity,
//       height: 3,

//       decoration: BoxDecoration(
//         color: const Color(0xFFDDE8EC),
//         borderRadius: BorderRadius.circular(10),
//       ),

//       child: Align(
//         alignment: Alignment.centerLeft,

//         child: FractionallySizedBox(
//           widthFactor: 1 / 6,

//           child: Container(
//             decoration: BoxDecoration(
//               color: primaryColor,
//               borderRadius:
//                   BorderRadius.circular(10),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // TEXT FIELD
//   // ============================================================

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hintText,
//     required TextInputType keyboardType,
//   }) {
//     return SizedBox(
//       height: 21,

//       child: TextField(
//         controller: controller,

//         keyboardType: keyboardType,

//         style: const TextStyle(
//           color: darkText,
//           fontSize: 8,
//         ),

//         decoration: InputDecoration(
//           hintText: hintText,

//           hintStyle: const TextStyle(
//             color: Color(0xFF7B8589),
//             fontSize: 7.5,
//           ),

//           filled: true,

//           fillColor: Colors.white,

//           contentPadding:
//               const EdgeInsets.symmetric(
//             horizontal: 8,
//             vertical: 5,
//           ),

//           enabledBorder:
//               const OutlineInputBorder(
//             borderSide: BorderSide(
//               color: fieldBorder,
//               width: 0.8,
//             ),
//           ),

//           focusedBorder:
//               const OutlineInputBorder(
//             borderSide: BorderSide(
//               color: primaryColor,
//               width: 1,
//             ),
//           ),

//           border:
//               const OutlineInputBorder(
//             borderSide: BorderSide(
//               color: fieldBorder,
//               width: 0.8,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // BOTTOM BUTTON
//   // ============================================================

//   Widget _buildBottomButton() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.fromLTRB(
//         12,
//         10,
//         12,
//         10,
//       ),

//       decoration: const BoxDecoration(
//         color: backgroundColor,
//       ),

//       child: SizedBox(
//         width: double.infinity,
//         height: 28,

//         child: ElevatedButton(
//           onPressed: _nextStep,

//           style: ElevatedButton.styleFrom(
//             backgroundColor: primaryColor,
//             foregroundColor: Colors.white,

//             elevation: 0,

//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 10,
//             ),

//             shape:
//                 RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(18),
//             ),
//           ),

//           child: const Text(
//             'Next Step →',
//             style: TextStyle(
//               fontSize: 8,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // NEXT STEP
//   // ============================================================

//   void _nextStep() {
//     if (_fullNameController.text
//             .trim()
//             .isEmpty ||
//         _phoneController.text
//             .trim()
//             .isEmpty ||
//         _emailController.text
//             .trim()
//             .isEmpty ||
//         _ageController.text
//             .trim()
//             .isEmpty ||
//         _occupationController.text
//             .trim()
//             .isEmpty) {
//       _showMessage(
//         'Please complete all fields.',
//       );

//       return;
//     }

//     // For now, show confirmation.
//     // You can replace this with Step 2 later.

//     _showMessage(
//       'Step 1 completed for ${widget.pet['name']}.',
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),

//         behavior:
//             SnackBarBehavior.floating,

//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }