import 'package:flutter/material.dart';
import 'legal_screen.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalScreen(
      title: 'Política de Privacidad',
      lastUpdated: '29 de agosto de 2026',
      sections: [
        LegalSection(
          '1. Introducción',
          'En FamilyApp nos tomamos muy en serio la privacidad de tu información. Esta política explica qué datos recopilamos, cómo los usamos y qué derechos tienes sobre ellos.',
        ),
        LegalSection(
          '2. Información que recopilamos',
          'Recopilamos la información que proporcionas al crear tu cuenta: nombre, apellidos, correo electrónico y teléfono. También almacenamos el contenido que creas dentro de la aplicación, como tareas, eventos y la configuración de tu familia.',
        ),
        LegalSection(
          '3. Uso de la información',
          'Utilizamos tus datos para ofrecer, mantener y mejorar el servicio: sincronizar tus tareas y eventos, permitir la colaboración familiar, enviar recordatorios y notificaciones, y brindar soporte técnico.',
        ),
        LegalSection(
          '4. Almacenamiento y seguridad',
          'Tus datos se almacenan de forma segura en servicios en la nube con cifrado en tránsito y en reposo. Implementamos medidas técnicas y organizativas para proteger tu información contra accesos no autorizados, pérdida o alteración.',
        ),
        LegalSection(
          '5. Compartición de información',
          'No vendemos ni alquilamos tus datos personales a terceros. La información dentro de una familia se comparte únicamente entre los miembros de esa familia, según los roles asignados.',
        ),
        LegalSection(
          '6. Derechos del usuario',
          'Tienes derecho a acceder, corregir, eliminar y solicitar una copia de tus datos personales. Puedes editar tu perfil desde la aplicación o solicitar la eliminación de tu cuenta escribiéndonos por correo.',
        ),
        LegalSection(
          '7. Retención de datos',
          'Conservamos tus datos mientras tu cuenta esté activa. Si eliminas tu cuenta, tus datos personales se eliminarán de forma definitiva, salvo que la ley exija conservarlos por un período mayor.',
        ),
        LegalSection(
          '8. Privacidad de menores',
          'FamilyApp está pensada para el uso familiar. Si un menor utiliza la aplicación, se requiere que un adulto responsable sea el titular de la cuenta y supervise el uso. No recopilamos intencionadamente datos de menores sin el consentimiento de sus padres o tutores.',
        ),
        LegalSection(
          '9. Cambios en esta política',
          'Podemos actualizar esta política periódicamente. Publicaremos cualquier cambio dentro de la aplicación y actualizaremos la fecha de revisión. Te recomendamos revisar esta política con regularidad.',
        ),
        LegalSection(
          '10. Contacto',
          'Si tienes dudas sobre esta Política de Privacidad, escríbenos a privacidad@familyapp.com.',
        ),
      ],
    );
  }
}
