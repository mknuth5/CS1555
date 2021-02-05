import java.io.File;
import java.sql.Date;
import java.sql.Timestamp;
import java.io.FileNotFoundException;
import java.sql.*;
import java.util.Scanner;

public class team14javaAdminFuncs{
    public team14javaAdminFuncs(){

    }
    public void eraseDB(Connection conn){
        try {
    	Statement st = conn.createStatement();
        String reservation_detail = "DELETE FROM reservation_detail WHERE TRUE";
        String airline= "DELETE FROM airline WHERE TRUE";
        String airlineprice= "DELETE FROM airlineprice WHERE TRUE";
        String customer= "DELETE FROM customer WHERE TRUE";
        String flight= "DELETE FROM flight WHERE TRUE";
        String ourtimestamp= "DELETE FROM ourtimestamp WHERE TRUE";
        String plane= "DELETE FROM plane WHERE TRUE";
        String price= "DELETE FROM price WHERE TRUE";
        String reservation= "DELETE FROM reservation WHERE TRUE";
        
        st.executeUpdate(reservation_detail);
        st.executeUpdate(flight);
        st.executeUpdate(plane);
        
        st.executeUpdate(airlineprice);
        st.executeUpdate(price);
        st.executeUpdate(reservation);
        st.executeUpdate(customer);
        st.executeUpdate(airline);
        st.executeUpdate(ourtimestamp);
        
        
        
        }
        catch(Exception e) {
        	System.out.println(e.getMessage());
        }
    }
    public void loadAirline(Connection conn, String filename){

    	Scanner scanner = new Scanner(System.in);
    	try
        {
          scanner = new Scanner(new File(filename));
        }
        catch(FileNotFoundException s)
        {
          System.out.println("File does Not Exist");
          return;
        }

    	PreparedStatement prep = null;
    	try {
    		conn.setAutoCommit(false);
    		prep = conn.prepareStatement("insert into airline values(?,?,?,?)");
    		String line = "";
        	while(scanner.hasNextLine())
        	{
        		line = scanner.nextLine();
        		String[] split = line.split("\\s+");
        		if(split.length < 4) {
                    System.out.println("Invalid line length.");
        			scanner.close();
        			return;
        		}
        		int airlineID,year;
        		try{
        			 airlineID = Integer.parseInt(split[0]);
        			 year = Integer.parseInt(split[split.length-1]);
        		}
        		catch(Exception e) {
        			System.out.println("invalid file format");
        			scanner.close();
        			return;
        		}
                String abv = split[split.length-2];
                String airlineName = "";
                for(int i = 1; i<split.length-2; i++){
                    airlineName = airlineName + split[i] + " ";
                }
                airlineName = airlineName.substring(0,airlineName.length()-1);
        		try {
        			 prep.setInt(1,airlineID);
        			 prep.setString(2, airlineName);
        			 prep.setString(3, abv);
        			 prep.setInt(4, year);
        			 prep.execute();
        		}
        		catch(Exception e) {
        			System.out.println("Invalid File Format");
        			scanner.close();
        			conn.rollback();
        			return;
        		}
        	}
        	conn.commit();
        	conn.setAutoCommit(true);
    	}
    	catch(Exception e) {
    		return;
    	}
    	scanner.close();
    }
    public void loadSchedule(Connection conn,String filename){
    	Scanner scanner = new Scanner(System.in);
    	try
        {
          scanner = new Scanner(new File(filename));
        }
        catch(FileNotFoundException s)
        {
          System.out.println("File does Not Exist");
          return;
        }

    	PreparedStatement prep = null;
    	try {
    		conn.setAutoCommit(false);
    		prep = conn.prepareStatement("insert into flight values(?,?,?,?,?,?,?,?)");
    		String line = "";
        	while(scanner.hasNextLine())
        	{
        		line = scanner.nextLine();
        		String[] split = line.split("\\s+");
        		if(split.length < 8) {
                    System.out.println("Invalid line length.");
        			scanner.close();
        			return;
        		}
        		int flight_number,airline_id,departure_time,arrival_time;
        		try {
        			flight_number = Integer.parseInt(split[0]);
        			airline_id = Integer.parseInt(split[1]);
        			departure_time = Integer.parseInt(split[5]);
        			arrival_time = Integer.parseInt(split[6]);
        		}
        		catch(Exception e) {
        			System.out.println("Invalid File Format");
        			scanner.close();
        			return;
        		}
        		try {
        			prep.setInt(1, flight_number);
        			prep.setInt(2, airline_id);
        			prep.setString(3, split[2]);
        			prep.setString(4, split[3]);
        			prep.setString(5, split[4]);
        			prep.setInt(6,departure_time);
        			prep.setInt(7, arrival_time);
        			prep.setString(8, split[7]);
        			prep.execute();
        		}
        		catch(Exception e) {
        			System.out.println(e.getMessage());
        			conn.rollback();
        			scanner.close();
        			return;
        		}
        	}
        	conn.commit();
        	conn.setAutoCommit(true);
    	}
    	catch(Exception e) {
    		System.out.println("Invalid File Format");
    	}
    }
    public void loadPricesC(Connection conn,String deptCity, String arrCity, String highPrice, String lowPrice){
    	try {
    		PreparedStatement prep = conn.prepareStatement("update price set (high_price,low_price) = (?,?) where departure_city = ? and arrival_city = ?");
    		prep.setInt(1, Integer.parseInt(highPrice));
    		prep.setInt(2, Integer.parseInt(lowPrice));

    		prep.setString(3, deptCity);
    		prep.setString(4, arrCity);
    		prep.execute();
    	}
    	catch(Exception e) {
    		System.out.println("Data could not be entered");
    		return;
    	}
    	
    }
    public void loadPricesL(Connection conn, String filename){
    	Scanner scanner = new Scanner(System.in);
    	try
        {
          scanner = new Scanner(new File(filename));
        }
        catch(FileNotFoundException s)
        {
          System.out.println("File does Not Exist");
          return;
        }

    	PreparedStatement prep = null;
    	try {
    		conn.setAutoCommit(false);
    		prep = conn.prepareStatement("insert into price values(?,?,?,?,?)");
    		String line = "";
        	while(scanner.hasNextLine())
        	{
        		line = scanner.nextLine();
        		String[] split = line.split("\\s+");
        		if(split.length < 5) {
                    System.out.println("Invalid line length.");
        			scanner.close();
        			return;
        		}
        		int airline_id, highPrice, lowPrice;
        		try {
        			airline_id = Integer.parseInt(split[2]);
        			highPrice = Integer.parseInt(split[3]);
        			lowPrice = Integer.parseInt(split[4]);
        		}
        		catch(Exception e) {
        			System.out.println("File format error....Airline_ID, High_Price, Low_Price should be numbers");
        			scanner.close();
        			return;
        		}
        		try {
        			prep.setString(1,split[0]);
        			prep.setString(2, split[1]);
        			prep.setInt(3,airline_id);
        			prep.setInt(4, highPrice);
        			prep.setInt(5,lowPrice);
        			prep.execute();
        		}
        		catch(Exception e) {
        			System.out.println("Input Error: Data has not been added. Data is either overlapping or in the wrong format");
        			scanner.close();
        			conn.rollback();
        			return;
        			
        		}
        		
        	}
        	conn.commit();
        	scanner.close();
        	conn.setAutoCommit(true);
    	}
    	
    	catch(Exception e) {
    		System.out.println("Input Error: data has not been added");
    		return;
    	}
    	
    }
    public void loadPlanes(Connection conn,String fileName){
    	Scanner scanner = new Scanner(System.in);
    	try
        {
          scanner = new Scanner(new File(fileName));
        }
        catch(FileNotFoundException s)
        {
          System.out.println("File does Not Exist");
          return;
        }

    	PreparedStatement prep = null;
    	try {
    		conn.setAutoCommit(false);
    		prep = conn.prepareStatement("insert into plane values(?,?,?,?,?,?)");
    		String line = "";
        	while(scanner.hasNextLine())
        	{
        		line = scanner.nextLine();
        		String[] split = line.split("\\s+");
        		if(split.length < 6) {
                    System.out.println("Invalid line length.");
        			scanner.close();
        			return;
        		}
        		String planeType,manufacturer,date;
        		int capacity,year,owner_id;
        		planeType = split[0];
        		date = split[split.length-3];
        		Date sqlDate;	
        		String convertedDate = ""+ date.substring(date.length()-4, date.length()) + "-" + date.substring(3, 5) + "-" + date.substring(0, 2);        		
        		try {
        			owner_id = Integer.parseInt(split[split.length-1]);
        			year = Integer.parseInt(split[split.length-2]);
        			capacity = Integer.parseInt(split[split.length-4]);
    				sqlDate = Date.valueOf(convertedDate);
        		}
        		catch(Exception e) {
        			System.out.println(e.getMessage());
        			System.out.println("Input Error: data has not been added");
            		scanner.close();
            		return;
        		}
        		manufacturer = "";
        		for(int i = 1; i<split.length-4; i++) {
        			manufacturer = manufacturer + split[i] + " ";
        		}
        		manufacturer = manufacturer.substring(0,manufacturer.length()-1);
        		try {
        			prep.setString(1,planeType);
        			prep.setString(2, manufacturer);
        			prep.setInt(3,capacity);
        			prep.setDate(4, sqlDate);
        			prep.setInt(5,year);
        			prep.setInt(6, owner_id);
        			prep.execute();
        		}
        		catch(Exception e) {
        			
        			System.out.println("Input Error: Data has not been added. Data is either overlapping or in the wrong format");
        			scanner.close();
        			conn.rollback();
        			return;
        		}
        		      		
        	}
        	conn.commit();
        	scanner.close();
        	conn.setAutoCommit(true);
    	}
    	catch(Exception e) {
    		System.out.println("Input Error: data has not been added");
    		scanner.close();
    		return;
    	}
    }
    public void getManifest(Connection conn,String flightNum, String datetime){
    	PreparedStatement prep;
    	try {
    	prep = conn.prepareStatement("SELECT salutation,first_name,last_name "
    			+ "FROM flight INNER JOIN RESERVATION_DETAIL RD on FLIGHT.flight_number = RD.flight_number "
    			+ "INNER JOIN RESERVATION R on RD.reservation_number = R.reservation_number "
    			+ "INNER JOIN CUSTOMER C on R.cid = C.cid WHERE FLIGHT.flight_number = ? AND flight_date = ?");
    	}
    	catch(Exception e) {
    		System.out.println("Prepared Statement error");
    		return;
    	}
    	Timestamp dateTime = null;
		
    	try {
    		dateTime = Timestamp.valueOf(datetime);
    	}
    	catch(Exception e) {
    		System.out.println("Date is not in proper format. Please use YYYY-MM-DD HH:MM:SS format");
    		return;
    	}
    	ResultSet set = null;
    	try {
    		prep.setInt(1, Integer.parseInt(flightNum));
    		prep.setTimestamp(2,dateTime);
    		set = prep.executeQuery();
    	}
    	catch(Exception e) {
    		System.out.println("Data search error.");
    		return;
    	}
    	try {
    	ResultSetMetaData rsmd = set.getMetaData();
    	int columnsNumber = rsmd.getColumnCount();
    	while (set.next()) {
    	    for (int i = 1; i <= columnsNumber; i++) {
    	        if (i > 1) System.out.print(" ");
    	        String columnValue = set.getString(i);
    	        System.out.print(columnValue);
    	    }
    	    System.out.println("");
    	}
    	}
    	catch(Exception e) {
    		System.out.println("Display Error");
    		return;
    	}
    }
    public void updateTimestamp(Connection conn,String time, String date){
    	PreparedStatement prep;
    	try {
    		prep = conn.prepareStatement("UPDATE ourtimestamp SET c_timestamp = ? WHERE TRUE");
    		Timestamp dateTime = Timestamp.valueOf(date+" "+time);
    		prep.setTimestamp(1,dateTime);
    		prep.execute();
    	}
    	catch(Exception e) {
    		System.out.println("Format Error: date should be in format yyyy-mm-dd and time should be in format hh:mm:ss");
    	}
    }
}
