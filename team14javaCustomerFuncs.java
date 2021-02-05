import java.sql.*;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Properties;
import java.util.ArrayList;
import java.util.List;

public class team14javaCustomerFuncs{
    public ArrayList<String> cities = new ArrayList<String>();
    public team14javaCustomerFuncs(){
    }
    //1
    @SuppressWarnings("deprecation")
	public int addCustomer (Connection conn,String sal,
                            String fname, String lname,
                            String street,String city,
                            String state,String phonenum,
                            String email,String ccnum,
                            String cced,String freqmil){
        try(Statement getMaxCID = conn.createStatement();
            PreparedStatement insertNewCust = conn.prepareStatement("INSERT into customer values(?,?,?,?,?,?,?,?,?,?,?,?);")){
            ResultSet rs = getMaxCID.executeQuery("Select max(cid) from customer;");
            rs.next();
            int maxCID = rs.getInt("max");
            int cid = maxCID+1;

            String[] expire = cced.split("-|/");

            insertNewCust.setInt(1,cid);
            insertNewCust.setString(2,sal);
            insertNewCust.setString(3,fname);
            insertNewCust.setString(4,lname);
            insertNewCust.setString(5,ccnum);
            insertNewCust.setDate(6,new Date(Integer.parseInt(expire[2])-1900,Integer.parseInt(expire[0])-1,Integer.parseInt(expire[1])));
            insertNewCust.setString(7,street);
            insertNewCust.setString(8,city);
            insertNewCust.setString(9,state);
            insertNewCust.setString(10,phonenum);
            insertNewCust.setString(11,email);
            insertNewCust.setString(12,freqmil);

            return insertNewCust.executeUpdate();
        }catch(SQLException e){
            System.err.println(e.getMessage());
            return -1;
        }


    }
    //2 done
    public void getCustomerInfo(Connection conn,String fname,
                                String lname){
        try(PreparedStatement getCustInfo = conn.prepareStatement("Select * from customer where first_name=? and last_name=?;")){
            getCustInfo.setString(1,fname);
            getCustInfo.setString(2,lname);
            ResultSet custInfo = getCustInfo.executeQuery();
            custInfo.next();

            System.out.println();
            System.out.println("CID: "+custInfo.getInt("cid"));
            System.out.println("Salutation: "+custInfo.getString("salutation"));
            System.out.println("First Name: "+custInfo.getString("first_name"));
            System.out.println("Last Name: "+custInfo.getString("last_name"));
            System.out.println("Credit Card Num: "+custInfo.getString("credit_card_num"));
            System.out.println("Credit Card Expire Date: "+custInfo.getDate("credit_card_expire"));
            System.out.println("Street: "+custInfo.getString("street"));
            System.out.println("City: "+custInfo.getString("city"));
            System.out.println("Phone: "+custInfo.getString("phone"));
            System.out.println("Email: "+custInfo.getString("email"));
            System.out.println("Frequent Miles: "+custInfo.getString("frequent_miles"));
            System.out.println();

        }catch(SQLException e){
            System.err.println(e.getMessage());
        }
    }

    public int CityToInt(String city){
        if(cities.contains(city)){
            return cities.indexOf(city);
        }else{
            cities.add(city);
            return cities.indexOf(city);
        }
    }

    public String InttoCity(int index){
        return cities.get(index);
    }

    public void printFlightDetails(String cityA,String cityB,int hp, int lp){
        System.out.println("For a flight from "+cityA+" to "+cityB);
        System.out.println("The high price will be $"+hp);
        System.out.println("The low price will be $"+lp);
        System.out.println();
    }

    public boolean roundTripAvailable(Connection conn, ArrayList<Integer> flights){
        try(PreparedStatement AtoB = conn.prepareStatement("Select * from price where departure_city = ? and arrival_city = ?;");){
            String cityA="";
            String cityB="";
            ResultSet connFlights;
            for(int i=flights.size()-1;i>0;i--){
                cityA = InttoCity(flights.get(i));
                cityB = InttoCity(flights.get(i-1));
                //System.out.println(cityA+" to "+cityB);
                AtoB.setString(1,cityA);
                AtoB.setString(2,cityB);
                connFlights = AtoB.executeQuery();
                if(connFlights.next()){

                }else{
                    return false;
                }

            }
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }
        return true;
    }

    //3 WIP
    public void flightPrice(Connection conn,String tempcityA,String tempcityB){
        try(PreparedStatement AtoB = conn.prepareStatement("Select * from price where departure_city = ? and arrival_city = ?;");
            Statement flights = conn.createStatement();
            Statement count = conn.createStatement();){

            String cityA = tempcityA.toUpperCase();
            String cityB = tempcityB.toUpperCase();
            System.out.println();
            System.out.println("Direct Flights: ");
            System.out.println();
            AtoB.setString(1,cityA);
            AtoB.setString(2,cityB);
            ResultSet AtoBDir = AtoB.executeQuery();

            if(AtoBDir.next()){
                printFlightDetails(AtoBDir.getString("departure_city"),
                                    AtoBDir.getString("arrival_city"),
                                    AtoBDir.getInt("high_price"),
                                    AtoBDir.getInt("low_price"));
            }else{
                System.out.println("There are no direct flights from "+cityA+" to "+cityB);
                System.out.println();
            }

            AtoB.setString(1,cityB);
            AtoB.setString(2,cityA);
            ResultSet BtoA = AtoB.executeQuery();
            if(BtoA.next()){
                printFlightDetails(BtoA.getString("departure_city"),
                                    BtoA.getString("arrival_city"),
                                    BtoA.getInt("high_price"),
                                    BtoA.getInt("low_price"));
            }else{
                System.out.println("There are no direct flights from "+cityB+" to "+cityA);
                System.out.println();
            }



            System.out.println("Connecting Flights: ");
            System.out.println();
            ResultSet c = count.executeQuery("select distinct count(departure_city) as cnt from price;");
            c.next();
            Graph g = new Graph(c.getInt("cnt"));
            ResultSet f = flights.executeQuery("select * from price;");
            while(f.next()){
                g.addEdge(CityToInt(f.getString("departure_city")),CityToInt(f.getString("arrival_city")));
            }
            ResultSet connFlights;
            g.printAllPaths(CityToInt(cityA),CityToInt(cityB));
            ArrayList<ArrayList<Integer>> paths =  g.getPaths();
            if(paths.size()>1){
                for(int i=0; i< paths.size();i++){
                    System.out.println("Flight Path "+(i+1));
                    for(int j=0;j<paths.get(i).size()-1;j++){
                        cityA = InttoCity(paths.get(i).get(j));
                        cityB = InttoCity(paths.get(i).get(j+1));
                        //System.out.println(cityA+" to "+cityB);
                        AtoB.setString(1,cityA);
                        AtoB.setString(2,cityB);
                        connFlights = AtoB.executeQuery();
                        while(connFlights.next()){
                            printFlightDetails(connFlights.getString("departure_city"),
                                                connFlights.getString("arrival_city"),
                                                connFlights.getInt("high_price"),
                                                connFlights.getInt("low_price"));
                        }
                        //System.out.print(InttoCity(paths.get(i).get(j))+"->");
                    }
                    if(roundTripAvailable(conn,paths.get(i))){
                        System.out.println("Return path for Flight Path "+(i+1));
                        System.out.println();
                        for(int k=paths.get(i).size()-1;k>0;k--){
                            cityA = InttoCity(paths.get(i).get(k));
                            cityB = InttoCity(paths.get(i).get(k-1));
                            //System.out.println(cityA+" to "+cityB);
                            AtoB.setString(1,cityA);
                            AtoB.setString(2,cityB);
                            connFlights = AtoB.executeQuery();
                            while(connFlights.next()){
                                printFlightDetails(connFlights.getString("departure_city"),
                                                    connFlights.getString("arrival_city"),
                                                    connFlights.getInt("high_price"),
                                                    connFlights.getInt("low_price"));
                            }
                        }
                    }else{
                        System.out.println("No round trip available for this flight path");
                    }
                    System.out.println();
                }
            }else{
                System.out.println("No available flights connecting "+cityA+" to "+cityB);
            }

        }catch(SQLException e){
            System.err.println(e.getMessage());
        }
    }

    public boolean sameDayCheck(String f1sched,String f2sched){
        String[] flight1 = f1sched.split("");
        String[] flight2 = f2sched.split("");
        for(int i=0;i<flight1.length;i++){
            if(flight1[i].equals(flight2[i])){
                return true;
            }
        }
        return false;
    }

    //4 done
    public void Routes(Connection conn,String tempdepCity,String temparrCity){
        try(PreparedStatement direct = conn.prepareStatement("select flight_number, departure_city, departure_time, arrival_time from flight natural left join airline where departure_city = ? and arrival_city=?;");
            PreparedStatement departures = conn.prepareStatement("select * from flight natural left join airline where departure_city=?;");
            PreparedStatement arrivals = conn.prepareStatement("select * from flight natural left join airline where arrival_city=?;",ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_READ_ONLY)){
            String depCity = tempdepCity.toUpperCase();
            String arrCity = temparrCity.toUpperCase();
            direct.setString(1,depCity);
            direct.setString(2,arrCity);
            ResultSet directflight = direct.executeQuery();
            boolean first=true;
            while(directflight.next()){
                if(first){
                    System.out.println("Direct Flights from "+depCity+" -> "+arrCity);
                    first=false;
                }
                System.out.println("Flight Number: "+directflight.getInt("flight_number"));
                System.out.println("Departure City: "+directflight.getString("departure_city"));
                System.out.println("Departure Time: "+directflight.getInt("departure_time"));
                System.out.println("Arrival Time: "+directflight.getInt("arrival_time"));
            }


            departures.setString(1,depCity);
            arrivals.setString(1,arrCity);
            ResultSet depSet = departures.executeQuery();
            ResultSet arrSet = arrivals.executeQuery();

            System.out.println();
            first=true;
            while(depSet.next()){
                while(arrSet.next()){
                    if(depSet.getString("arrival_city").equals(arrSet.getString("departure_city"))){
                        if (sameDayCheck(depSet.getString("weekly_schedule"),arrSet.getString("weekly_schedule"))){
                            if(first){
                                System.out.println("Connecting Flights from "+depCity+" -> "+arrCity);
                                first=false;
                            }
                            System.out.println("Flight 1");
                            System.out.println("Flight Number: "+depSet.getInt("flight_number"));
                            System.out.println("Departure City: "+depSet.getString("departure_city"));
                            System.out.println("Departure Time: "+depSet.getInt("departure_time"));
                            System.out.println("Arrival Time: "+depSet.getInt("arrival_time"));
                            System.out.println();

                            System.out.println("Flight 2");
                            System.out.println("Flight Number: "+arrSet.getInt("flight_number"));
                            System.out.println("Departure City: "+arrSet.getString("departure_city"));
                            System.out.println("Departure Time: "+arrSet.getInt("departure_time"));
                            System.out.println("Arrival Time: "+arrSet.getInt("arrival_time"));
                        }
                    }
                }
                arrSet.first();
            }

        }catch(SQLException e){
            System.err.println(e.getMessage());
        }

    }

    //5
    public void airlineRoutes(Connection conn, String tempdepCity,String temparrCity,String airline){
        try(PreparedStatement direct = conn.prepareStatement("select airline_id,flight_number,departure_city, departure_time, arrival_time from flight natural left join airline where departure_city = ? and arrival_city=? and airline_name=?;");
            PreparedStatement departures = conn.prepareStatement("select * from flight natural left join airline where departure_city=? and airline_name=?;");
            PreparedStatement arrivals = conn.prepareStatement("select * from flight natural left join airline where arrival_city=? and airline_name=?;",ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_READ_ONLY)){
            String depCity = tempdepCity.toUpperCase();
            String arrCity = temparrCity.toUpperCase();
            direct.setString(1,depCity);
            direct.setString(2,arrCity);
            direct.setString(3,airline);
            ResultSet directflight = direct.executeQuery();
            boolean first=true;
            while(directflight.next()){
                if(first){
                    System.out.println("Direct Flights from "+depCity+" -> "+arrCity);
                    first=false;
                }
                System.out.println("Flight Number: "+directflight.getInt("flight_number"));
                System.out.println("Airline ID: "+directflight.getString("airline_id"));
                System.out.println("Departure City: "+directflight.getString("departure_city"));
                System.out.println("Departure Time: "+directflight.getInt("departure_time"));
                System.out.println("Arrival Time: "+directflight.getInt("arrival_time"));
            }


            departures.setString(1,depCity);
            departures.setString(2,airline);
            arrivals.setString(1,arrCity);
            arrivals.setString(2,airline);
            ResultSet depSet = departures.executeQuery();
            ResultSet arrSet = arrivals.executeQuery();

            System.out.println();
            first=true;
            while(depSet.next()){
                while(arrSet.next()){
                    if(depSet.getString("arrival_city").equals(arrSet.getString("departure_city"))){
                        if (sameDayCheck(depSet.getString("weekly_schedule"),arrSet.getString("weekly_schedule"))){
                            if(first){
                                System.out.println("Connecting Flights from "+depCity+" -> "+arrCity);
                                first=false;
                            }
                            System.out.println("Flight 1");
                            System.out.println("Flight Number: "+depSet.getInt("flight_number"));
                            System.out.println("Airline ID: "+depSet.getString("airline_id"));
                            System.out.println("Departure City: "+depSet.getString("departure_city"));
                            System.out.println("Departure Time: "+depSet.getInt("departure_time"));
                            System.out.println("Arrival Time: "+depSet.getInt("arrival_time"));
                            System.out.println();

                            System.out.println("Flight 2");
                            System.out.println("Flight Number: "+arrSet.getInt("flight_number"));
                            System.out.println("Airline ID: "+arrSet.getString("airline_id"));
                            System.out.println("Departure City: "+arrSet.getString("departure_city"));
                            System.out.println("Departure Time: "+arrSet.getInt("departure_time"));
                            System.out.println("Arrival Time: "+arrSet.getInt("arrival_time"));
                        }
                    }
                }
                arrSet.first();
            }

        }catch(SQLException e){
            System.err.println(e.getMessage());
        }
    }

    public boolean hasSeats(Connection conn, PreparedStatement check)throws SQLException{
        ResultSet full = check.executeQuery();
        full.next();
        if(full.getBoolean("isplanefull")){
            System.out.println("Full");
            return false;
        }
        return true;
    }

    //6
    public void availableRoutes(Connection conn, String tempdepCity,String temparrCity, String date){
        try(PreparedStatement direct = conn.prepareStatement("select flight_number, departure_city, departure_time, arrival_time from flight natural left join airline where departure_city = ? and arrival_city=?;");
            PreparedStatement departures = conn.prepareStatement("select * from flight natural left join airline where departure_city=?;");
            PreparedStatement arrivals = conn.prepareStatement("select * from flight natural left join airline where arrival_city=?;",ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_READ_ONLY);
            PreparedStatement checkSeats = conn.prepareStatement("Select isPlaneFull(?,?)")){
            String depCity = tempdepCity.toUpperCase();
            String arrCity = temparrCity.toUpperCase();
            direct.setString(1,depCity);
            direct.setString(2,arrCity);
            ResultSet directflight = direct.executeQuery();
            boolean first=true;
            String[] dateSplit = date.split("-|/");
            int month = Integer.parseInt(dateSplit[0]) - 1;
            int day= Integer.parseInt(dateSplit[1]);
            int year = Integer.parseInt(dateSplit[2])-1900;
            @SuppressWarnings("deprecation")
			Timestamp flightdate = new Timestamp(year,month,day,0,0,0,0);
            while(directflight.next()){
                checkSeats.setInt(1,directflight.getInt("flight_number"));
                checkSeats.setTimestamp(2,flightdate);
                if(hasSeats(conn,checkSeats)){
                    if(first){
                        System.out.println("Direct Flights from "+depCity+" -> "+arrCity);
                        first=false;
                    }
                    System.out.println("Flight Number: "+directflight.getInt("flight_number"));
                    System.out.println("Departure City: "+directflight.getString("departure_city"));
                    System.out.println("Departure Time: "+directflight.getInt("departure_time"));
                    System.out.println("Arrival Time: "+directflight.getInt("arrival_time"));
                }
            }


            departures.setString(1,depCity);
            arrivals.setString(1,arrCity);
            ResultSet depSet = departures.executeQuery();
            ResultSet arrSet = arrivals.executeQuery();

            System.out.println();
            first=true;
            while(depSet.next()){
                while(arrSet.next()){
                    if(depSet.getString("arrival_city").equals(arrSet.getString("departure_city"))){
                        if (sameDayCheck(depSet.getString("weekly_schedule"),arrSet.getString("weekly_schedule"))){
                            checkSeats.setInt(1,directflight.getInt("flight_number"));
                            checkSeats.setTimestamp(2,flightdate);
                            //check multiple dates?
                            if(hasSeats(conn,checkSeats)){
                                if(first){
                                    System.out.println("Connecting Flights from "+depCity+" -> "+arrCity);
                                    first=false;
                                }
                                System.out.println("Flight 1");
                                System.out.println("Flight Number: "+depSet.getInt("flight_number"));
                                System.out.println("Departure City: "+depSet.getString("departure_city"));
                                System.out.println("Departure Time: "+depSet.getInt("departure_time"));
                                System.out.println("Arrival Time: "+depSet.getInt("arrival_time"));
                                System.out.println();

                                System.out.println("Flight 2");
                                System.out.println("Flight Number: "+arrSet.getInt("flight_number"));
                                System.out.println("Departure City: "+arrSet.getString("departure_city"));
                                System.out.println("Departure Time: "+arrSet.getInt("departure_time"));
                                System.out.println("Arrival Time: "+arrSet.getInt("arrival_time"));
                            }
                        }
                    }
                }
                arrSet.first();
            }

        }catch(SQLException e){
            System.err.println(e.getMessage());
        }
    }

    //7 done
    public void makeReservation(Connection conn,int resnum, int flightNum, String depDate,int leg){
        try(PreparedStatement makeRes = conn.prepareStatement("Call makeReservation(?,?,?,?);")){
            makeRes.setInt(1,resnum);
            makeRes.setInt(2,flightNum);
            makeRes.setString(3,depDate);
            makeRes.setInt(4,leg);

            makeRes.executeQuery();

            System.out.println("Thank you");
        }catch(SQLException e){
            System.err.println(e.getMessage());
        }
    }

    //8 Should be done, assuming trigger on reservation_detail correctly performs downgrade check
    public void deleteReservation(Connection conn, int resnum){
        try(PreparedStatement cancelRes = conn.prepareStatement("Delete from reservation where reservation_number=?;")){
            cancelRes.setInt(1,resnum);
            cancelRes.executeUpdate();
        }catch(SQLException e){
            System.err.println(e.getMessage());
        }
    }

    //9 done
    public void resInfo(Connection conn, int resnum){
        try(PreparedStatement resInfo = conn.prepareStatement("Select * from reservation_detail natural join flight where reservation_number=?;")){
            resInfo.setInt(1,resnum);

            System.out.println("Reservation Number: "+resnum);
            System.out.println();
            ResultSet res = resInfo.executeQuery();
            while(res.next()){
                System.out.println("Leg: "+res.getInt("leg"));
                System.out.println("Flight Number: "+res.getInt("flight_number"));
                System.out.println("Flight date: "+res.getDate("flight_date"));
                System.out.println("Airline ID: "+res.getInt("airline_id"));
                System.out.println("Plane Type: "+res.getString("plane_type"));
                System.out.println("Departure City: "+res.getString("departure_city"));
                System.out.println("Arrival City: "+res.getString("arrival_city"));
                System.out.println();
            }

        }catch(SQLException e){
            System.err.println(e.getMessage());
        }
    }

    //10 done
    public void buyTicket(Connection conn, int resnum){
        try(PreparedStatement buy = conn.prepareStatement("update reservation set ticketed=true where reservation_number=?;")){
            buy.setInt(1,resnum);
            buy.executeUpdate();
        }catch(SQLException e){
            System.err.println(e.getMessage());
        }
    }
    public int StringtoInt(String num){
        return Integer.parseInt(num);
    }
    public boolean FreqMilesDiscount(ResultSet reservation)throws SQLException{
        return reservation.getString("frequent_miles").equals(reservation.getString("airline_abbreviation"));
    }


    public void updateAirlinePriceTable(Connection conn,int cid,String airabb ,float price){
        try(PreparedStatement update = conn.prepareStatement("update airlinePrice set price=price+? where cid=? and airline_abbreviation=?;");
            PreparedStatement insert = conn.prepareStatement("insert into airlinePrice select ?,?,? where not exists(select 1 from airlinePrice where cid = ? and airline_abbreviation=?)")){
            update.setFloat(1,price);
            update.setInt(2,cid);
            update.setString(3,airabb);

            insert.setInt(1,cid);
            insert.setString(2,airabb);
            insert.setFloat(3,price);
            insert.setInt(4,cid);
            insert.setString(5,airabb);

            update.executeUpdate();
            insert.executeUpdate();
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }
    }//

    public void getAirlinePrices(Connection conn,int cid, ResultSet reservation,int legs) throws SQLException{
        reservation.next();
            if(legs==1){
                if(StringtoInt(reservation.getString("arrival_time")) - StringtoInt(reservation.getString("departure_time")) > 0){
                    if(FreqMilesDiscount(reservation)){
                        updateAirlinePriceTable(conn,cid,reservation.getString("airline_abbreviation"),reservation.getInt("high_price")*.9f);
                        //tripPrice+=reservation.getInt("high_price")*.9;
                    }else{
                        updateAirlinePriceTable(conn,cid,reservation.getString("airline_abbreviation"),reservation.getInt("high_price"));
                        //tripPrice+=reservation.getInt("high_price");
                    }
                }else{
                    if(FreqMilesDiscount(reservation)){
                        updateAirlinePriceTable(conn,cid,reservation.getString("airline_abbreviation"),reservation.getInt("low_price")*.9f);
                        //tripPrice+= reservation.getInt("low_price")*.9;                    }
                    }else{
                        updateAirlinePriceTable(conn,cid,reservation.getString("airline_abbreviation"),reservation.getInt("low_price"));
                        //tripPrice+=reservation.getInt("low_price");
                    }
                }
            }else{
                Date start = reservation.getDate("flight_date");
                reservation.last();
                Date end = reservation.getDate("flight_date");
                reservation.first();
                if(start == end){
                    while(reservation.next()){
                        if(FreqMilesDiscount(reservation)){
                            updateAirlinePriceTable(conn,cid,reservation.getString("airline_abbreviation"),reservation.getInt("high_price")*.9f);
                            //tripPrice+=reservation.getInt("high_price")*.9;
                        }else{
                            updateAirlinePriceTable(conn,cid,reservation.getString("airline_abbreviation"),reservation.getInt("high_price"));
                            //tripPrice+=reservation.getInt("high_price");
                        }
                    }
                }else{
                    do{
                        if(FreqMilesDiscount(reservation)){
                            updateAirlinePriceTable(conn,cid,reservation.getString("airline_abbreviation"),reservation.getInt("low_price")*.9f);
                            //tripPrice+=reservation.getInt("low_price")*.9;
                        }else{
                            updateAirlinePriceTable(conn,cid,reservation.getString("airline_abbreviation"),reservation.getInt("low_price"));
                            //tripPrice+=reservation.getInt("low_price");
                        }
                    }while(reservation.next());
                }
            }
    }

    public void setupAirlinePrices(Connection conn){
        try(PreparedStatement res = conn.prepareStatement("select *"+
                                                            "from reservation_detail natural join reservation natural join flight natural join airline natural join price natural join customer where reservation_number=?;",ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_READ_ONLY);
            Statement getresnums = conn.createStatement();
            PreparedStatement maxlegs =conn.prepareStatement("select max(leg) as numlegs from reservation_detail where reservation_number=?") ){
            ResultSet resNums = getresnums.executeQuery("select * from reservation;");
            while(resNums.next()){
                int cid = resNums.getInt("cid");
                int resnum = resNums.getInt("reservation_number");
                res.setInt(1,resnum);
                ResultSet reservation = res.executeQuery();
                maxlegs.setInt(1,resnum);
                ResultSet numlegs = maxlegs.executeQuery();
                numlegs.next();
                getAirlinePrices(conn,cid,reservation,numlegs.getInt("numlegs"));
            }

        }catch(Exception e){
            System.out.println(e.getMessage());
        }
    }

    //11
    public void topKCustomers(Connection conn, int k){
        try(Statement airlines = conn.createStatement();
        PreparedStatement costper = conn.prepareStatement("select cid from airlineprice where airline_abbreviation=? order by price desc limit ?;"); ){
            ResultSet airabb = airlines.executeQuery("select * from airline");
            while(airabb.next()){
                costper.setString(1,airabb.getString("airline_abbreviation"));
                costper.setInt(2,k);
                ResultSet airlineRanks = costper.executeQuery();
                System.out.println();
                System.out.println("Airline "+airabb.getString("airline_abbreviation"));
                while(airlineRanks.next()){
                    System.out.println(airlineRanks.getInt("cid"));
                }
            }
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }

    }

    //12 done
    public void topKTravelers(Connection conn, int k){
        try(Statement airlines = conn.createStatement();
            PreparedStatement travelers = conn.prepareStatement("select count(airline_id) as cnt,cid " +
                                                                "from reservation natural left join reservation_detail natural left join flight natural join airline " +
                                                                "where airline_id = ? "+
                                                                "group by reservation_number " +
                                                                "order by cnt desc "+
                                                                "limit ?;")){
            ResultSet num = airlines.executeQuery("Select count(airline_id) as cnt from airline");
            num.next();
            int numairlines = num.getInt("cnt");
            travelers.setInt(2,k);
            for(int i=1;i<=numairlines;i++){
                travelers.setInt(1, i);
                ResultSet travelrank = travelers.executeQuery();
                System.out.println("Airline "+i+" Rankings");
                while(travelrank.next()){
                    System.out.println(travelrank.getInt("cid"));
                }
                System.out.println();
            }
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }

    }

    //13 done
    public void customerSatisfaction(Connection conn){
        try(Statement custsat = conn.createStatement()){
            ResultSet rankings = custsat.executeQuery("select airline_id, count(reservation_number) as cnt" +
                                                        " from reservation natural left join reservation_detail natural left join flight natural join airline" +
                                                        " where ticketed" +
                                                        " group by airline_id" +
                                                        " order by cnt desc;");
            System.out.println("Airline Rankings:");
            while(rankings.next()){
                System.out.println(rankings.getInt("airline_id"));
            }
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }

    }

    public static void main(String[] args)throws SQLException,ClassNotFoundException{
        Class.forName("org.postgresql.Driver");
        String url = "jdbc:postgresql://localhost/postgres";
        Properties props = new Properties();
        props.setProperty("user", "postgres");
        props.setProperty("password", "password");
        //Connection conn = DriverManager.getConnection(url, props);

        //addCustomer(conn,"MR","John","Joe","Meyran","Pittsburgh","PA","9084878232","ser89@pitt.edu","1234567891234467","12/01/2020","ALASKA");
        //getCustomerInfo(conn,"John","Joe");
        //customerSatisfaction(conn);
    }
}

class Graph {
    private int c;
    private ArrayList<Integer>[] flightList;
    private ArrayList<ArrayList<Integer>> paths = new ArrayList<ArrayList<Integer>>();
    public Graph(int cities){
        this.c = cities;
        flightList();
    }
    @SuppressWarnings("unchecked")
    private void flightList(){
        flightList = new ArrayList[c];
        for (int i = 0; i < c; i++) {
            flightList[i] = new ArrayList<>();
        }
    }

    public void addEdge(int start, int end){
        flightList[start].add(end);
    }

    public void printAllPaths(int s, int e){
        boolean[] isVisited = new boolean[c];
        ArrayList<Integer> pathList = new ArrayList<>();
        pathList.add(s);
        printAllPathsUtil(s, e, isVisited, pathList);
    }

    public ArrayList<ArrayList<Integer>> getPaths(){
        return paths;
    }

    public void addPath(ArrayList<Integer> path){
        //System.out.println("Adding path: "+path);
        ArrayList<Integer> newPath = new ArrayList<Integer>();
        for(int i: path){
            newPath.add(i);
        }
        paths.add(newPath);

    }

    private void printAllPathsUtil(int s, int e, boolean[] isVisited, ArrayList<Integer> localPathList){
        if (s == e) {
            addPath(localPathList);
            return;
        }
        isVisited[s] = true;
        for (Integer i : flightList[s]) {
            if (!isVisited[i]) {
                localPathList.add(i);
                printAllPathsUtil(i, e, isVisited, localPathList);
                localPathList.remove(i);
            }
        }
        isVisited[s] = false;
    }
}
