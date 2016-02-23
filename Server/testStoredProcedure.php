<?php
echo "1<br>";


$host = "mysql:host=localhost;dbname=test";
$user = "root";
$pass = "root";
$cn= new PDO( $host, $user, $pass );

$mode = 3;
$sql = "";

//MODO #1
if ( $mode == 1 ) {

    $sth = $cn->prepare("call insertUser( ?, ?, ?, ?, @out)");
    $a = "xxxxxxx";
    $b = "yyyyyyy";
    $c = 12.12300001;
    $d = 12.12300001;
    $sth->bindParam(1, $a);
    $sth->bindParam(2, $b);
    $sth->bindParam(3, $c);
    $sth->bindParam(4, $d);
    $sth->execute();
}

//MODO #2
if ( $mode == 2 ){

    //$sql = "call insertUser( 'MODO2x', 'MODO2y', 34.6666, 23.5555)";

    $sth = $cn->prepare("call insertUser( :name, :lastname, :lat, :lng, @out)");
    $a = "MODO2x";
    $b = "MODO2y";
    $c = 32.123009;
    $d = 22.12300001;
    $sth->bindParam(":name", $a);
    $sth->bindParam(":lastname", $b);
    $sth->bindParam(":lat", $c);
    $sth->bindParam(":lng", $d);
    $sth->execute();
}

//MODO #3
if ( $mode == 3 ){

    $sql = "call insertUser( 'MODO3x', 'MODO3y', 35.6666, 43.5555, @out)";

    $sth = $cn->prepare( $sql );
    $sth->execute();

    // in alternative
    //$cn->exec( $sql );
}

//MODO #4
if ( $mode == 4 ) {

    $sql = "call insertUser( :name, :lastname, :lat, :lng, @out)";
    $sql = "call selectUser( :id )";
    $sql = "call $functionName()";

    $sth = $cn->prepare($sql, array(PDO::ATTR_CURSOR => PDO::CURSOR_FWDONLY)); // fuziona anche senza array

    $a = "MODO4x";
    $b = "MODO4y";
    $c = 28.123009;
    $d = 19.12300001;

    $sth->execute(array(':name' => $a, ':lastname' => $b, ':lat' => $c, ':lng' => $d));
}

//MODO #5
if ( $mode == 5 ){

    $sql = "Select * from element";
    $sth = $cn->prepare( $sql );
    $sth->execute( );

    echo $sql."<br>";
    print_r( $sth->fetchAll(PDO::FETCH_ASSOC) );
}


echo "<br>2";


/*
 * PDO sequence of operations
 *
 * 1- Define host user and pwd clearly (use user= root and pwd = root when you don't have a specific user defined
 * 2-Create the query
 *
 * */

/*
 * prepare()
 *
 * Prepares an SQL statement to be executed by the PDOStatement::execute() method.
 * The SQL statement can contain zero or more named (:name) or question mark (?) parameter markers for
 * which real values will be substituted when the statement is executed.
 *
 * 1 - You cannot use both named and question mark parameter markers within the same SQL statement;
 * pick one or the other parameter style.
 *
 * 2 - Use these parameters to bind any user-input, do not include the user-input directly in the query.
 */
