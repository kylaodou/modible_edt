import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modible_edt/core/theme/colors.dart';
import 'package:modible_edt/widgets/Onboarding_data.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final onboardingData = OnboardingData();
  final pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body()),
            navigationButtons(),
          ],
        ),
      ),
    );
  }

  // BuildDots - Optimisé pour responsive
  Widget buildDots() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          onboardingData.items.length,
              (index) => AnimatedContainer(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: currentIndex == index ? primaryColor : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
            height: 7,
            width: currentIndex == index ? 35 : 10,
            duration: const Duration(milliseconds: 700),
          ),
        ),
      ),
    );
  }

  // Body optimisé pour responsive
  Widget body() {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.height < 600;

    return Stack(
      children: [
        Center(
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            itemCount: onboardingData.items.length,
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Calculer les marges et tailles en fonction de l'espace disponible
                  final availableHeight = constraints.maxHeight;
                  final contentPadding = EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.05,
                    vertical: isSmallScreen ? 10 : 15,
                  );

                  // Calculer la hauteur proportionnelle pour l'animation
                  final animationHeight = isSmallScreen
                      ? availableHeight * 0.35 // Plus petit sur petits écrans
                      : availableHeight * 0.45; // Plus grand sur grands écrans

                  // Espacements adaptatifs
                  final titleSpacing = isSmallScreen ? 5.0 : 10.0;
                  final dotsSpacing = isSmallScreen ? 10.0 : 20.0;

                  return Padding(
                    padding: contentPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animation Lottie avec taille relative
                        SizedBox(
                          height: animationHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Lottie.asset(
                                onboardingData.items[index].image[1],
                                fit: BoxFit.contain,
                              ),
                              Lottie.asset(
                                onboardingData.items[index].image[0],
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),

                        // Dots avec espacement adaptatif
                        Padding(
                          padding: EdgeInsets.all(dotsSpacing),
                          child: buildDots(),
                        ),

                        // Titre avec taille de texte adaptative
                        Text(
                          onboardingData.items[index].title,
                          style: TextStyle(
                              fontSize: isSmallScreen ? 22 : 26,
                              fontWeight: FontWeight.bold,
                              color: primaryColor
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Description avec espacement et taille adaptative
                        SizedBox(height: titleSpacing),
                        Text(
                          onboardingData.items[index].description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: isSmallScreen ? 14 : 16
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Back button avec positionnement relatif
        if (currentIndex > 0)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
              onPressed: () {
                pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
      ],
    );
  }

  // Navigation Buttons avec taille responsive
  Widget navigationButtons() {
    final screenSize = MediaQuery.of(context).size;
    final isLastPage = currentIndex == onboardingData.items.length - 1;
    final bool isSmallScreen = screenSize.height < 600;

    // Ajustement des marges pour différentes tailles d'écran
    final horizontalPadding = screenSize.width * 0.05;
    final verticalPadding = isSmallScreen ? 15.0 : 25.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        mainAxisAlignment: isLastPage
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          // Skip button
          if (!isLastPage)
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 10 : 15,
                ),
              ),
              onPressed: () {
                pageController.animateToPage(
                    onboardingData.items.length - 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut
                );
              },
              child: const Text(
                'Sauter',
                style: TextStyle(color: primaryColor),
              ),
            ),

          // Action button avec taille adaptative
          ElevatedButton(
            onPressed: () {
              if (isLastPage) {
                print('Commencer l\'application');
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => MainPage()),
                // );
              } else {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 30,
                vertical: isSmallScreen ? 10 : 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              // Taille adaptative du bouton
              minimumSize: isLastPage
                  ? Size(screenSize.width - (horizontalPadding * 2), isSmallScreen ? 40 : 50)
                  : Size(isSmallScreen ? 40 : 50, isSmallScreen ? 40 : 50),
            ),
            child: isLastPage
                ? Text("Commencer", style: TextStyle(fontSize: isSmallScreen ? 14 : 16))
                : const Icon(Icons.arrow_forward),
          )
        ],
      ),
    );
  }
}