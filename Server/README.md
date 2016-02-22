DEVELOPMENT INFORMATION
=======================

### If you want to know more about: ###
> STORED PROCEDURE 

> TRIGGER

> an their integration with PHP PDO.

You can read some documentation to these links underneath (beneath):
--------------------------------------------------------------------
### PDO and Stored Procedures: ###

1. ["Example"](http://example.com/)

1. ["Bind Param"](http://php.net/manual/it/pdostatement.bindparam.php)

1. ["Prepare Statement"](http://php.net/manual/en/pdo.prepared-statements.php)

1. ["Stored Procedures"](http://www.sitepoint.com/stored-procedures-mysql-php/)
### Trigger integration with PHP: ###

["Triggers"](http://www.sitepoint.com/action-automation-with-mysql-triggers/)
### Security of passwords: ###

["Security"](https://crackstation.net/hashing-security.htm)
### FrontController: ### 

["Front"](http://www.sitepoint.com/front-controller-pattern-2/)
### MVC for Noobs: ###

["Link Mvc"](http://code.tutsplus.com/tutorials/mvc-for-noobs--net-10488)

A web application is usually composed of a set of controllers, models and views. The controller may be structured as a main controller that receives all requests and calls specific controllers that handles actions for each case
### Write your framework: ###

["Framework link"](http://anantgarg.com/2009/03/13/write-your-own-php-mvc-framework-part-1/)

### Other: ###
["Other link"](https://www.thoughtworks.com)

## NOTES: ##

1 - The function call_user_func_array( array( <class>, <method> ), <array_parameters> );

Example 1:

```
#!php

class A {
function B( $param1, $param2 ){
echo "parameters: ".$param1." ".$param2;
}
}

call_user_func_array( array( "A","B" ), array("one", "two") );

/** Output **/
// parameters: one two

```
Example 2

We want an array as input, so $param must be and array()


```
#!php

class A {
function B( $param ){
echo "parameters: ".$param;
echo "<br>type: ".gettype($param);
}
}

```

If you call the function in this way:


```
#!php

$array = ("one", "two", "three");
call_user_func_array( array( "A","B" ), $array );

```
The output will be:
```
#!php

/** Output **/
// parameters: one
// type: string

```

In fact the function sees the array as a sequence of parameters and tekes the only ones it needs.
If you want to get around this problem you should do like this:


```
#!php

$array = ("one", "two", "three");
call_user_func_array( array( "A","B" ), array($array) );

/** Output **/
// parameters: array() << should be printed with print_r
// type: array


```
In this way you pass an array as if it is the first function parameter.