import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        InterfaceClient ic = new InterfaceClient();
        Scanner scanner = new Scanner(System.in);
        boolean connecte = false;

        do {
            int choix;
            do {
                System.out.println("\n1. s'incrire");
                System.out.println("2. se connecter");
                choix = scanner.nextInt();
            } while (choix < 1 || choix > 2);

            connecte = switch (choix) {
                case 1 -> ic.sInscrire();
                case 2 -> ic.seConnecter();
                default -> connecte;
            };
        } while (!connecte);

        System.out.println("Bienvenue sur l'interface !\n");

        while (true) {
            int choix;
            do {
                System.out.println("\n1. Voir les événements d’une salle particulière triés par date");
                System.out.println("2. Voir ses réservations");
                System.out.println("3. Voir les festivals futurs");
                System.out.println("4. Voir les événements auxquels participe un artiste particulier triés par date");
                choix = scanner.nextInt();
            } while (choix < 1 || choix > 4);

            switch (choix) {
                case 1: ic.afficherEvenementsParSalle();
                    break;
                case 2: ic.afficherReservations();
                    break;
                case 3: ic.afficherFestivalsFuturs();
                    break;
                case 4: ic.afficherEvenementsParArtiste();
                    break;
            }
        }
    }
}
