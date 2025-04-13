import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBarWidget extends StatefulWidget {
  final int indexCourant;
  final Function(int) changerPage;
  final Color primaryColor;

  const BottomNavBarWidget({
    Key? key,
    required this.indexCourant,
    required this.changerPage,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget>
    with TickerProviderStateMixin {
  // Contrôleurs d'animation pour chaque icône
  late List<AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    // Créer 4 contrôleurs d'animation pour les 4 onglets
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    // Démarrer l'animation pour l'onglet initialement sélectionné
    if (widget.indexCourant >= 0 &&
        widget.indexCourant < _animationControllers.length) {
      _animationControllers[widget.indexCourant].forward();
    }
  }

  @override
  void didUpdateWidget(BottomNavBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si l'index sélectionné a changé
    if (widget.indexCourant != oldWidget.indexCourant) {
      // Arrêter l'animation précédente
      if (oldWidget.indexCourant >= 0 &&
          oldWidget.indexCourant < _animationControllers.length) {
        _animationControllers[oldWidget.indexCourant].reverse();
      }

      // Démarrer la nouvelle animation
      if (widget.indexCourant >= 0 &&
          widget.indexCourant < _animationControllers.length) {
        _animationControllers[widget.indexCourant].forward();
      }
    }
  }

  @override
  void dispose() {
    // Disposer tous les contrôleurs d'animation
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: GNav(
            selectedIndex: widget.indexCourant,
            onTabChange: widget.changerPage,
            color: widget.primaryColor,
            activeColor: Colors.white,
            tabBackgroundColor: widget.primaryColor,
            padding: const EdgeInsets.all(10),
            gap: 5,
            tabs: [
              GButton(
                icon: CupertinoIcons.home,
                text: "Accueil",
                leading: AnimatedBuilder(
                  animation: _animationControllers[0],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_animationControllers[0].value * 0.2),
                      child: Icon(
                        CupertinoIcons.home,
                        color: widget.indexCourant == 0
                            ? Colors.white
                            : widget.primaryColor,
                      ),
                    );
                  },
                ),
              ),
              GButton(
                icon: CupertinoIcons.calendar,
                text: "Emploi du temps",
                leading: AnimatedBuilder(
                  animation: _animationControllers[1],
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationControllers[1].value * 0.3,
                      child: Icon(
                        CupertinoIcons.calendar,
                        color: widget.indexCourant == 1
                            ? Colors.white
                            : widget.primaryColor,
                      ),
                    );
                  },
                ),
              ),
              GButton(
                icon: CupertinoIcons.bell,
                text: "Notifications",
                leading: AnimatedBuilder(
                  animation: _animationControllers[2],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -3 * _animationControllers[2].value),
                      child: Transform.rotate(
                        angle: _animationControllers[2].value * 0.2,
                        child: Icon(
                          CupertinoIcons.bell,
                          color: widget.indexCourant == 2
                              ? Colors.white
                              : widget.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
              GButton(
                icon: FontAwesomeIcons.user,
                iconSize: 22,
                text: "Profil",
                leading: AnimatedBuilder(
                  animation: _animationControllers[3],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_animationControllers[3].value * 0.2),
                      child: Icon(
                        FontAwesomeIcons.user,
                        size: 22,
                        color: widget.indexCourant == 3
                            ? Colors.white
                            : widget.primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
