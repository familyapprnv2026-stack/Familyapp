import 'package:flutter/material.dart';
import 'legal_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalScreen(
      title: 'Términos y Condiciones',
      lastUpdated: '29 de agosto de 2026',
      sections: [
        LegalSection(
          '1. Aceptación de los términos',
          'Al descargar, acceder o utilizar FamilyApp, aceptas cumplir con estos Términos y Condiciones y con nuestra Política de Privacidad. Si no estás de acuerdo con alguna parte de estos términos, no utilices la aplicación.',
        ),
        LegalSection(
          '2. Descripción del servicio',
          'FamilyApp es una aplicación diseñada para organizar tareas domésticas, eventos familiares y facilitar la comunicación dentro del núcleo familiar. El servicio permite a los miembros crear asignaciones, calendarios compartidos y gestionar la vida cotidiana de manera colaborativa.',
        ),
        LegalSection(
          '3. Cuentas de usuario',
          'Para usar FamilyApp debes crear una cuenta con un correo electrónico válido y una contraseña. Eres responsable de mantener la confidencialidad de tus credenciales y de todas las actividades realizadas con tu cuenta. Debes proporcionar información veraz y mantenerla actualizada.',
        ),
        LegalSection(
          '4. Familias y roles',
          'Cada familia cuenta con un administrador (dueño) que puede gestionar la composición del grupo y la configuración. Los miembros tienen acceso a las tareas y eventos compartidos según el rol que se les haya asignado. El administrador es responsable de invitar a los miembros.',
        ),
        LegalSection(
          '5. Uso aceptable',
          'Te comprometes a utilizar FamilyApp de forma lícita y respetuosa. Queda prohibido publicar contenido ilegal, ofensivo, difamatorio o que infrinja los derechos de terceros, así como intentar acceder a cuentas de otros usuarios sin autorización.',
        ),
        LegalSection(
          '6. Propiedad intelectual',
          'La aplicación, su diseño, imágenes, logos y textos son propiedad de sus desarrolladores. No se concede ningún derecho de uso sobre ellos, salvo una licencia limitada, no exclusiva e intransferible para el uso personal de la aplicación.',
        ),
        LegalSection(
          '7. Limitación de responsabilidad',
          'FamilyApp se ofrece "tal cual". No garantizamos que el servicio esté libre de errores o interrupciones. En la medida permitida por la ley, no seremos responsables por daños directos o indirectos derivados del uso o la imposibilidad de uso de la aplicación.',
        ),
        LegalSection(
          '8. Modificaciones',
          'Podremos modificar estos términos en cualquier momento. Notificaremos los cambios mediante la aplicación o por correo. El uso continuado del servicio tras la publicación de los cambios implica la aceptación de los nuevos términos.',
        ),
        LegalSection(
          '9. Contacto',
          'Para consultas sobre estos Términos y Condiciones, puedes escribirnos a soporte@familyapp.com.',
        ),
      ],
    );
  }
}
