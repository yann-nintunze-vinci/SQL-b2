import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        System.out.println("test");
        InterfaceClient ic = new InterfaceClient();

        System.out.println("festivals futurs:");
        ic.afficherFestivalsFuturs();
        System.out.println();

        System.out.println("reservations client:");
        System.out.print("Ecrivez l'id d'un client : ");
        Scanner s = new Scanner(System.in);
        ic.afficherReservationsClient(s.nextInt());
        System.out.println();


        System.out.println("evenements par salle");
        System.out.print("Ecrivez l'id d'une salle : ");
        ic.afficherEvenementsParSalle(s.nextInt());
        System.out.println();

        System.out.println("evenements par artiste");
        System.out.print("Ecrivez l'id d'un artiste : ");
        ic.afficherEvenementsParArtiste(s.nextInt());
        System.out.println();


    }
}
