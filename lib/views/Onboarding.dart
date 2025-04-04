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
      body: Column(
        children: [
          Expanded(child: body()),
          navigationButtons(),
        ],
      ),
    );
  }

// BuildDots - Moved to appear right after the image
  Widget buildDots() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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

  // Updated body() with back button and dots repositioning
  Widget body() {
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
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Limiter la taille de l'animation Lottie
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      //Lotties
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
                    // Dots ajoutés juste après l'image
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: buildDots(),
                    ),
                    //Titre

                    Text(
                      onboardingData.items[index].title,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    //Description
                    const SizedBox(height: 10),
                    Text(
                      onboardingData.items[index].description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Flèche pour revenir en arrière (visible seulement si pas sur la première page)
        if (currentIndex > 0)
          Positioned(
            top: 50,
            left: 20,
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

  // Navigation Buttons updated
  Widget navigationButtons() {
    final isLastPage = currentIndex == onboardingData.items.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Row(
        mainAxisAlignment: isLastPage
            ? MainAxisAlignment.center  // Centré pour le dernier écran
            : MainAxisAlignment.spaceBetween,  // Espacé pour les autres écrans
        children: [
          // Skip button - visible seulement si pas sur la dernière page
          if (!isLastPage)
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
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

          // Button with full width on last page or arrow on other pages
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
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              // Élargir le bouton sur la dernière page
              minimumSize: isLastPage
                  ? Size(MediaQuery.of(context).size.width - 40, 50)
                  : const Size(50, 50),
            ),
            child: isLastPage
                ? const Text("Commencer", style: TextStyle(fontSize: 16))
                : const Icon(Icons.arrow_forward),
          )
        ],
      ),
    );
  }
}