import 'package:modible_edt/widgets/OnboardingInfo.dart';

class OnboardingData {

  List<OnboardingInfo> items = [
    OnboardingInfo(
        title: "Organisez votre journée",
        description: "Planifiez facilement vos cours, réunions et rendez-vous pour rester maître de votre emploi du temps.",
        image: ["assets/lotties/lottie-1.json", "assets/lotties/confeti.json"]
    ),


    OnboardingInfo(
        title: "Visualisez vos activités",
        description: "Accédez à une vue claire et intuitive de vos tâches quotidiennes et hebdomadaires pour mieux anticiper vos journées.",
        image: ["assets/lotties/lottie-2.json", "assets/lotties/confeti.json"]
    ),

    OnboardingInfo(
        title: "Restez informé",
        description: "Connectez vous pour recevoir des rappels et notifications pour ne jamais manquer un événement important et rester toujours à jour.",
        image: ["assets/lotties/lottie-3.json", "assets/lotties/confeti.json"]
    ),


  ];
}