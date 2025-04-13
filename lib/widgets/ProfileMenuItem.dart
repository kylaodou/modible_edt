import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProfileMenuItem extends StatelessWidget {
  final String text;
  final Color containerColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const ProfileMenuItem({
    Key? key,
    required this.text,
    required this.containerColor,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: Colors.grey,
                size: 18,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
