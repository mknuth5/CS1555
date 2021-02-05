import java.util.Properties;
import java.io.IOException;
import java.sql.*;
import java.util.Scanner;

public class team14javadriver{
    public static void main(String args[])throws SQLException,ClassNotFoundException{
    	clearScreen();
        Connection conn = db();
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        customer.setupAirlinePrices(conn);
        while(true){
          Scanner input = new Scanner(System.in);
          System.out.println("Please enter in the number of what type of user you are or 9 to exit.");
          System.out.println("1. Administrator");
          System.out.println("2. Customer");
          String userType = input.nextLine();
          System.out.println(userType);
          if(userType.equals("1")){
        	clearScreen();
            adminUi(conn);
          }
          else if(userType.equals("2")){
        	clearScreen();
            userUi(conn);
          }
          else if(userType.equals("9")){
            System.out.println("Exiting the Program");
            break;
          }
          else{
            System.out.println("Your response was not understood please try again");
          }
        }
    }
    public static Connection db()throws SQLException,ClassNotFoundException{ //We need to handle having a failed connection
        Class.forName("org.postgresql.Driver");
        String url = "jdbc:postgresql://localhost/postgres";
        Properties props = new Properties();
        props.setProperty("user", "postgres");
        props.setProperty("password", "password");
        Connection conn = DriverManager.getConnection(url, props);

        return conn;
    }

    public static void adminUi(Connection conn)throws SQLException{
        team14javaAdminFuncs admin =  new team14javaAdminFuncs();
      while(true){
        Scanner input = new Scanner(System.in);
        System.out.println("");
        System.out.println("Welcome to Pitt Tours Administrator, please select an option.");
        System.out.println("1. Erase the database");
        System.out.println("2. Load airline information");
        System.out.println("3. Load schedule information");
        System.out.println("4. Load pricing information");
        System.out.println("5. Load plane information");
        System.out.println("6. Generate passenger manifest for specific flight on given day");
        System.out.println("7. Update the current timestamp");
        System.out.println("8. Exit the program");
        String adminInput = input.nextLine();
        if(adminInput.equals("1")){
            clearScreen();
            erase(conn);
        }
        else if(adminInput.equals("2")){
            clearScreen();
            loadAir(conn);
        }
        else if(adminInput.equals("3")){
            clearScreen();
            loadSch(conn);
        }
        else if(adminInput.equals("4")){
            clearScreen();
            loadPrice(conn);
        }
        else if(adminInput.equals("5")){
            clearScreen();
            loadPlane(conn);
        }
        else if(adminInput.equals("6")){
            clearScreen();
            manifest(conn);
        }
        else if(adminInput.equals("7")){
            clearScreen();
            updateTime(conn);
        }
        else if(adminInput.equals("8")){
            System.exit(0); //might need to do this in a much cleaner way
        }
        else{
          System.out.println("Your response was not understood please try again");
        }
      }
    }
    public static void userUi(Connection conn){
      while(true){
        Scanner input = new Scanner(System.in);
        System.out.println("");
        System.out.println("Welcome to Pitt Tours Customer, please select an option.");
        System.out.println("1.  Add customer");
        System.out.println("2.  Show customer info, given customer name");
        System.out.println("3.  Find price for flights between two cities");
        System.out.println("4.  Find all routes between two cities");
        System.out.println("5.  Find all routes between two cities of a given airline");
        System.out.println("6.  Find all routes with available seats between two cities on a given date");
        System.out.println("7.  Add reservation");
        System.out.println("8.  Delete reservation");
        System.out.println("9.  Show reservation info, given reservation number");
        System.out.println("10. Buy ticket from existing reservation");
        System.out.println("11. Find the top-k customers for each airline");
        System.out.println("12. Find the top-k traveled customers for each airline");
        System.out.println("13. Rank the airlines based on customer satisfaction");
        System.out.println("14. Exit the program");
        String cusInput = input.nextLine();

        if(cusInput.equals("1")){
            clearScreen();
            addCus(conn);
        }
        else if (cusInput.equals("2")){
            clearScreen();
            showInfo(conn);
        }
        else if (cusInput.equals("3")){
            clearScreen();
            findPrice(conn);
        }
        else if (cusInput.equals("4")){
            clearScreen();
            findRoute(conn);
        }
        else if (cusInput.equals("5")){
            clearScreen();
            findRouteAir(conn);
        }
        else if (cusInput.equals("6")){
            clearScreen();
            findRouteDate(conn);
        }
        else if (cusInput.equals("7")){
            clearScreen();
            addRev(conn);
        }
        else if (cusInput.equals("8")){
            clearScreen();
            delRev(conn);
        }
        else if (cusInput.equals("9")){
            clearScreen();
            showRev(conn);
        }
        else if (cusInput.equals("10")){
            clearScreen();
            buy(conn);
        }
        else if (cusInput.equals("11")){
            clearScreen();
            findCusMoney(conn);
        }
        else if (cusInput.equals("12")){
            clearScreen();
            findCusMiles(conn);
        }
        else if (cusInput.equals("13")){
            clearScreen();
            team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
            customer.customerSatisfaction(conn);
        }
        else if (cusInput.equals("14")){
            System.exit(0);
        }
        else{
          System.out.println("Your response was not understood please try again");
        }
      }
    }

    //Start of the Admin functions
    public static void erase(Connection conn){
        team14javaAdminFuncs admin =  new team14javaAdminFuncs();
        Scanner input = new Scanner(System.in);
        System.out.println("Are you sure that you want to erase the database?");
        System.out.println("1. Yes");
        System.out.println("2. No");
        String eraseInput = input.nextLine();

      if(eraseInput.equals("1")){
        System.out.println("The database will be erased");
        try{
            admin.eraseDB(conn);
        }
        catch(Exception ex){
            //throw new SQLException(ex);
            System.out.println(ex);
        }
      }
      else if(eraseInput.equals("2")){
        System.out.println("The database will not be erased");
      }
      else{
        System.out.println("Response not understood, The database will not be erased");
      }
    }

    public static void loadAir(Connection conn){
        team14javaAdminFuncs admin =  new team14javaAdminFuncs();
        Scanner input = new Scanner(System.in);
        System.out.println("Please enter the filename in which you would like to load airline information from.");
        String filename = input.nextLine();
        admin.loadAirline(conn,filename);
    }

    public static void loadSch(Connection conn){
        team14javaAdminFuncs admin =  new team14javaAdminFuncs();
        Scanner input = new Scanner(System.in);
        System.out.println("Please enter the filename in which you would like to load schedule information from.");
        String filename = input.nextLine();
        admin.loadSchedule(conn,filename);
    }

    public static void loadPrice(Connection conn){
        team14javaAdminFuncs admin =  new team14javaAdminFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please choose between L (Load pricing information) and C (change the price of an existing flight).");
        String choice = input.nextLine();
        if(choice.equals("C")){
            System.out.println("Please give the departure city.");
            String deptCity = input.nextLine();
            System.out.println("Please give the arrival city.");
            String arrCity = input.nextLine();
            System.out.println("Please give the high price.");
            String highPrice = input.nextLine();
            System.out.println("Please give the low price.");
            String lowPrice = input.nextLine();

            admin.loadPricesC(conn,deptCity,arrCity,highPrice,lowPrice);
        }
        else if(choice.equals("L")){
            System.out.println("Please enter the filename in which you would like to load pricing information from.");
            String filename = input.nextLine();

            admin.loadPricesL(conn,filename);
        }
        else{
            System.out.println("The entry was not reconnized.");
        }
    }

    public static void loadPlane(Connection conn){
        team14javaAdminFuncs admin =  new team14javaAdminFuncs();
        Scanner input = new Scanner(System.in);
        System.out.println("Please enter the filename in which you would like to load plane information from.");
        String filename = input.nextLine();
        admin.loadPlanes(conn,filename);
    }

    public static void manifest(Connection conn){
        team14javaAdminFuncs admin =  new team14javaAdminFuncs();
        Scanner input = new Scanner(System.in);
        System.out.println("Please supply the flight number.");
        String flightNum = input.nextLine();
        System.out.println("Please supply the date and time of the flight (YYYY-MM-DD HH:MM:SS).");
        String datetime = input.nextLine();
        admin.getManifest(conn,flightNum,datetime);
    }

    public static void updateTime(Connection conn){
        team14javaAdminFuncs admin =  new team14javaAdminFuncs();
        Scanner input = new Scanner(System.in);
        System.out.println("Please supply the time you wish to set (HH:MM:SS) in military time.");
        String time = input.nextLine();
        System.out.println("Please supply the date of the timestamp (YYYY-MM-DD).");
        String date = input.nextLine();
        admin.updateTimestamp(conn,time,date);
    }

    //Start of the Customer functions
    public static void addCus(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please enter the salutation (Mr/Mrs/Ms) of the customer.");
        String sal = input.nextLine();
        System.out.println("Please enter the first name of the customer.");
        String fname = input.nextLine();
        System.out.println("Please enter the last name of the customer.");
        String lname = input.nextLine();
        System.out.println("Please enter the street of the customer.");
        String street = input.nextLine();
        System.out.println("Please enter the address city of the customer.");
        String city = input.nextLine();
        System.out.println("Please enter the address state of the customer.");
        String state = input.nextLine();
        System.out.println("Please enter the phone number of the customer.");
        String phone = input.nextLine();
        System.out.println("Please enter the email address of the customer.");
        String email = input.nextLine();
        System.out.println("Please enter the credit card number of the customer.");
        String ccnum = input.nextLine();
        System.out.println("Please enter the credit card expiration date (MM/DD/YY) of the customer.");
        String expDate = input.nextLine();
        System.out.println("Please enter the frequent miles information of the customer.");
        String freq = input.nextLine();

        customer.addCustomer(conn,sal,fname,lname,street,city,state,phone,email,ccnum,expDate,freq);
    }

    public static void showInfo(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please enter the first name of the customer who you would like information for.");
        String fname = input.nextLine();
        System.out.println("Please enter the last name of the customer who you would like information for.");
        String lname = input.nextLine();

        customer.getCustomerInfo(conn, fname, lname);
    }

    public static void findPrice(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please enter the name of the first city.");
        String city1 = input.nextLine();
        System.out.println("Please enter the name of the second city.");
        String city2 = input.nextLine();

        customer.flightPrice(conn, city1, city2);
    }

    public static void findRoute(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);
        System.out.println("Please enter the name of the first city.");
        String city1 = input.nextLine();
        System.out.println("Please enter the name of the second city.");
        String city2 = input.nextLine();

        customer.Routes(conn, city1, city2);
    }

    public static void findRouteAir(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please enter the name of the first city.");
        String city1 = input.nextLine();
        System.out.println("Please enter the name of the second city.");
        String city2 = input.nextLine();
        System.out.println("Please enter the name of the airline.");
        String airline = input.nextLine();

        customer.airlineRoutes(conn, city1, city2, airline);
    }

    public static void findRouteDate(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please enter the name of the first city.");
        String city1 = input.nextLine();
        System.out.println("Please enter the name of the second city.");
        String city2 = input.nextLine();
        System.out.println("Please supply the date of the flight (MM/DD/YYYY).");
        String date = input.nextLine();

        customer.availableRoutes(conn, city1, city2, date);
    }

    public static void addRev(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please enter the reservation number.");
        int resNum = input.nextInt();
        System.out.println("Please enter the flight number.");
        int flightNum = input.nextInt();
        input.nextLine();
        System.out.println("Please supply the depature date of the flight (MM/DD/YYYY).");
        String depDate = input.nextLine();
        System.out.println("Please supply the leg of the flight.");
        int leg = input.nextInt();

        customer.makeReservation(conn,resNum,flightNum,depDate,leg);
    }

    public static void delRev(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please enter the reservation number.");
        int resNum = input.nextInt();

        customer.deleteReservation(conn,resNum);
    }

    public static void showRev(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please enter the reservation number.");
        int resNum = input.nextInt();

        customer.resInfo(conn,resNum);
    }

    public static void buy(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please enter the reservation number.");
        int resNum = input.nextInt();

        customer.buyTicket(conn,resNum);
    }

    public static void findCusMoney(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please supply the number of customers that you want to display");
        int k = input.nextInt();

        customer.topKCustomers(conn,k);
    }

    public static void findCusMiles(Connection conn){
        team14javaCustomerFuncs customer =  new team14javaCustomerFuncs();
        Scanner input = new Scanner(System.in);

        System.out.println("Please supply the number of customers that you want to display");
        int k = input.nextInt();

        customer.topKTravelers(conn,k);
    }


    public static void clearScreen() {
    	try {

            if (System.getProperty("os.name").contains("Windows"))

                new ProcessBuilder("cmd", "/c", "cls").inheritIO().start().waitFor();

            else

                Runtime.getRuntime().exec("clear");

        } catch (IOException | InterruptedException ex) {}
    }
}
