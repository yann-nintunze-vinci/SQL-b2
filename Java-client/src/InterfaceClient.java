import java.sql.*;

public class InterfaceClient {

    private Connection conn;

    public InterfaceClient() {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant");
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

    public void afficherFestivalsFuturs() {
        requeteSelect("festivals_futurs");
    }

    public void afficherReservationsClient(int id_client) {
        requeteSelect("reservations_clients", "client", id_client);
    }

    public void afficherEvenementsParSalle(int id_salle) {
        requeteSelect("evenements_par_salle", "salle", id_salle);
    }

    public void afficherEvenementsParArtiste(int id_artiste) {
        requeteSelect("evenements_par_artiste", "artiste", id_artiste);
    }

    private void requeteSelect(String table) {
        try {
            Statement s = conn.createStatement();
            try (ResultSet rs = s.executeQuery("SELECT * " +
                    "FROM gestion_evenements." + table + ";")) {
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                while (rs.next()) {
                    for (int i = 1; i <= columnCount; i++)
                        System.out.print(rs.getString(i) + " ");
                    System.out.println();
                }
            }
        } catch (SQLException se) {
            System.out.println("Erreur lors du select !");
            se.printStackTrace();
            System.exit(1);
        }
    }

    private void requeteSelect(String table, String champ, int id) {
        try {
            Statement s = conn.createStatement();
            try (ResultSet rs = s.executeQuery("SELECT * " +
                    "FROM gestion_evenements." + table + " WHERE " + champ + " = " + id + ";")) {
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                while (rs.next()) {
                    for (int i = 1; i <= columnCount; i++)
                        System.out.print(rs.getString(i) + " ");
                    System.out.println();
                }
            }
        } catch (SQLException se) {
            System.out.println("Erreur lors du select !");
            se.printStackTrace();
            System.exit(1);
        }
    }
}
