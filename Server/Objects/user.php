<?php

/*
 * User
 *
 * Class user with get and set methods
 */

class User {

    public $id;
    public $name;
    public $lastname;
    public $born;
    public $subscriptiondate;
    public $type;
    public $profilepicture;
    public $actual_lat;
    public $actual_lng;
    protected $password;
    public $mail;
    protected $delated;

    function __construct($input = false){
        if (is_array($input)) {
            foreach ($input as $key => $val) {
                // Note the $key instead of key.
                // This will give the value in $key instead of 'key' itself
                $this->$key = $val;
            }
        }
    }

    /**
     * @return mixed
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * @param mixed $id
     */
    public function setId($id)
    {
        $this->id = $id;
    }

    /**
     * @return mixed
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * @param mixed $name
     */
    public function setName($name)
    {
        $this->name = $name;
    }

    /**
     * @return mixed
     */
    public function getLastname()
    {
        return $this->lastname;
    }

    /**
     * @param mixed $lastname
     */
    public function setLastname($lastname)
    {
        $this->lastname = $lastname;
    }

    /**
     * @return mixed
     */
    public function getBorn()
    {
        return $this->born;
    }

    /**
     * @param mixed $born
     */
    public function setBorn($born)
    {
        $this->born = $born;
    }

    /**
     * @return mixed
     */
    public function getSubscriptiondate()
    {
        return $this->subscriptiondate;
    }

    /**
     * @param mixed $subscriptiondate
     */
    public function setSubscriptiondate($subscriptiondate)
    {
        $this->subscriptiondate = $subscriptiondate;
    }

    /**
     * @return mixed
     */
    public function getType()
    {
        return $this->type;
    }

    /**
     * @param mixed $type
     */
    public function setType($type)
    {
        $this->type = $type;
    }

    /**
     * @return mixed
     */
    public function getProfilepicture()
    {
        return $this->profilepicture;
    }

    /**
     * @param mixed $profilepicture
     */
    public function setProfilepicture($profilepicture)
    {
        $this->profilepicture = $profilepicture;
    }

    /**
     * @return mixed
     */
    public function getActualLat()
    {
        return $this->actual_lat;
    }

    /**
     * @param mixed $actual_lat
     */
    public function setActualLat($actual_lat)
    {
        $this->actual_lat = $actual_lat;
    }

    /**
     * @return mixed
     */
    public function getActualLng()
    {
        return $this->actual_lng;
    }

    /**
     * @param mixed $actual_lng
     */
    public function setActualLng($actual_lng)
    {
        $this->actual_lng = $actual_lng;
    }

    /**
     * @return mixed
     */
    public function getPassword()
    {
        return $this->password;
    }

    /**
     * @param mixed $password
     */
    public function setPassword($password)
    {
        $this->password = $password;
    }

    /**
     * @return mixed
     */
    public function getMail()
    {
        return $this->mail;
    }

    /**
     * @param mixed $mail
     */
    public function setMail($mail)
    {
        $this->mail = $mail;
    }

    /**
     * @return mixed
     */
    public function getDelated()
    {
        return $this->delated;
    }

    /**
     * @param mixed $delated
     */
    public function setDelated($delated)
    {
        $this->delated = $delated;
    }



    public function login($data){

        $param = json_decode($data);

        $sending = new JsonUtilities();
        $sending = $sending->fromJsonToArray($param->param);

        $db = new Database();
        $db->callProcedure("login", $sending);
        $result = $db->getResult();

        /*
         *
         *
         *
         * SET SESSION!!!!!!!
         *
         *
         *
         */

        echo json_encode($result);
    }



}