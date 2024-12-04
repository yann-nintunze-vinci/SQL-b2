import org.springframework.security.crypto.bcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class InterfaceClient {

    private Connection conn;
    private Scanner scanner = new Scanner(System.in);
    private int client;

    public InterfaceClient() {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant");
            e.printStackTrace();
            System.exit(1);
        }

        String url = "jdbc:postgresql://localhost:5432/evenement";

        try {
            conn = DriverManager.getConnection(url, "postgres", "savinho");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            e.printStackTrace();
            System.exit(1);
        }
    }

    public boolean aDejaUnCompte(String utilisateur) {
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT mot_de_passe FROM gestion_evenements.clients WHERE nom_utilisateur = ? ;");
            ps.setString(1, utilisateur);
            ResultSet rs = ps.executeQuery();

            return rs.next();
        } catch (SQLException e) {
            System.out.println("Erreur lors du select !");
            e.printStackTrace();
            System.exit(1);
        }
        System.out.println("Une erreur s'est produite");
        return false;
    }

    public boolean sInscrire() {
        System.out.println("nom d'utilisateur : ");
        String utilisateur = scanner.nextLine();

        if (aDejaUnCompte(utilisateur)) {
            System.out.println("l'utilisateur " + utilisateur + " existe déjà, Veuillez vous connecter");
            return false;
        }

        System.out.println("email : ");
        String email = scanner.nextLine();
        System.out.println("mot de passe : ");
        String mdp = scanner.nextLine();

        try {
            PreparedStatement ps = conn.prepareStatement("SELECT gestion_evenements.ajouter_client (?, ?, ?);");
            ps.setString(1, utilisateur);
            ps.setString(2, email);

            String sel = BCrypt.gensalt();
            String mdpAStocker = BCrypt.hashpw(mdp, sel);
            ps.setString(3, mdpAStocker);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                this.client = rs.getInt(1);
                System.out.println("se connecter : ");
                return seConnecter();
            }

        } catch (SQLException e) {
            System.out.println("Erreur lors du select !");
            e.printStackTrace();
            System.exit(1);
        }
        System.out.println("Une erreur s'est produite");
        return false;
    }

    public boolean seConnecter() {
        System.out.println("nom d'utilisateur : ");
        String utilisateur = scanner.nextLine();

        if (!aDejaUnCompte(utilisateur)) {
            System.out.println("l'utilisateur " + utilisateur + " n'existe pas, Veuillez vous inscrire");
            return false;
        }

        System.out.println("mot de passe : ");
        String mdp = scanner.nextLine();

        try {
            PreparedStatement ps = conn.prepareStatement("SELECT mot_de_passe, id_client FROM gestion_evenements.clients WHERE nom_utilisateur = ? ;");
            ps.setString(1, utilisateur);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String mdpHashe = rs.getString(1);
                this.client = rs.getInt(2);
                if (BCrypt.checkpw(mdp, mdpHashe)) {
                    return true;
                } else {
                    System.out.println("la combinaison nom d'utilisateur-mot de passe n'est pas correcte");
                    return false;
                }
            }

        } catch (SQLException e) {
            System.out.println("Erreur lors du select !");
            e.printStackTrace();
            System.exit(1);
        }
        System.out.println("Une erreur s'est produite");
        return false;
    }

    private void afficherLesSalles() {
        System.out.println("Voici toutes les salles");
        afficherQuery("SELECT id_salle, nom, ville, capacite FROM gestion_evenements.salles");
    }

    public void afficherEvenementsParSalle() {
        afficherLesSalles();
        System.out.println("Donnez l'id de la salle dont vous voulez voir les evenements : ");
        int id_salle = scanner.nextInt();

        try {
            PreparedStatement ps = conn.prepareStatement("SELECT nom_evenement, date_evenement, nom_salle, artistes, prix, est_complet FROM gestion_evenements.evenements_par_salle WHERE salle = ?;");
            ps.setInt(1, id_salle);
            ResultSet rs = ps.executeQuery();
            ResultSetMetaData rsmd = rs.getMetaData();
            int columnCount = rsmd.getColumnCount();
            List<Date> listeDates = new ArrayList<>();
            while (rs.next()) {
                System.out.print(rs.getRow() + ". ");
                for (int i = 1; i < columnCount; i++) {
                    if (i == 2) {
                        Date date = rs.getDate(i);
                        listeDates.add(date);
                        System.out.print(date + " ");
                    } else {
                        System.out.print(rs.getString(i) + " ");
                    }
                }
                System.out.println();
            }

            int numLigne;
            do {
                System.out.println("Donnez le num de la ligne que vous voulez reserver : ");
                numLigne = scanner.nextInt();
            } while (numLigne < 1 || numLigne > listeDates.size());

            Date date_reservation = listeDates.get(numLigne - 1);

            int nb_tickets;
            do {
                System.out.println("Donnez le nombre de tickets souhaités (entre 1 et 4)");
                nb_tickets = scanner.nextInt();
            } while (nb_tickets < 1 || nb_tickets > 4);

            PreparedStatement ps2 = conn.prepareStatement("SELECT gestion_evenements.ajouter_reservation(?, ?, ?, ?);");
            ps2.setInt(1, nb_tickets);
            ps2.setDate(2, date_reservation);
            ps2.setInt(3, id_salle);
            ps2.setInt(4, this.client);
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next())
                System.out.println("Reservation accomplie");

        } catch (SQLException e) {
            System.out.println("Erreur lors du select !");
            e.printStackTrace();
            System.exit(1);
        }
    }

    public void afficherReservations() {
        afficherQuery("SELECT nom_evenement, date_evenement, salle, num_reservation, nb_places_reservees FROM gestion_evenements.reservations_clients WHERE client = ?;", this.client);
    }

    public void afficherFestivalsFuturs() {
        afficherQuery("SELECT nom, date_1er_evenement, date_dernier_evenement, total_prix FROM gestion_evenements.festivals_futurs;");
    }

    private void afficherLesArtistes() {
        System.out.println("Voici tous les artistes");
        afficherQuery("SELECT id_artiste, nom, nationalite FROM gestion_evenements.artistes;");
    }

    public void afficherEvenementsParArtiste() {
        afficherLesArtistes();
        System.out.println("Donnez l'id de l'artiste dont vous voulez voir les evenements : ");
        int id_artiste = scanner.nextInt();
        afficherQuery("SELECT nom_evenement, date_evenement, nom_salle, artistes, prix, est_complet FROM gestion_evenements.evenements_par_artiste WHERE artiste = ?;", id_artiste);
    }

    private void afficherQuery(String query) {
        try {
            Statement s = conn.createStatement();
            try (ResultSet rs = s.executeQuery(query)) {
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                while (rs.next()) {
                    for (int i = 1; i < columnCount; i++)
                        System.out.print(rs.getString(i) + " ");
                    System.out.println();
                }
            }
        } catch (SQLException e) {
            System.out.println("Erreur lors du select !");
            e.printStackTrace();
            System.exit(1);
        }
    }

    private void afficherQuery(String query, int id) {
        try {
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            ResultSetMetaData rsmd = rs.getMetaData();
            int columnCount = rsmd.getColumnCount();
            while (rs.next()) {
                for (int i = 1; i < columnCount; i++)
                    System.out.print(rs.getString(i) + " ");
                System.out.println();
            }
        } catch (SQLException e) {
            System.out.println("Erreur lors du select !");
            e.printStackTrace();
            System.exit(1);
        }
    }
}
