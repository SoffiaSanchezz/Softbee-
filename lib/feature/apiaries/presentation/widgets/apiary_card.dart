import 'package:Softbee/feature/apiaries/domain/entities/apiary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApiaryCard extends StatelessWidget {
  final Apiary apiary;
  final VoidCallback onTap;

  const ApiaryCard({super.key, required this.apiary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.hive,
                  color: Color(0xFFFFC107),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apiary.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      apiary.location ?? 'Ubicación no especificada',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF757575)),
            ],
          ),
        ),
      ),
    );
  }
}
