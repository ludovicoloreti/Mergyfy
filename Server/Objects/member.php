<?php


class member{

    public $iduser;
    public $idgroup;
    public $accepted;
    public $role;
    public $joindate;

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
    public function getIduser()
    {
        return $this->iduser;
    }

    /**
     * @param mixed $iduser
     */
    public function setIduser($iduser)
    {
        $this->iduser = $iduser;
    }

    /**
     * @return mixed
     */
    public function getIdgroup()
    {
        return $this->idgroup;
    }

    /**
     * @param mixed $idgroup
     */
    public function setIdgroup($idgroup)
    {
        $this->idgroup = $idgroup;
    }

    /**
     * @return mixed
     */
    public function getAccepted()
    {
        return $this->accepted;
    }

    /**
     * @param mixed $accepted
     */
    public function setAccepted($accepted)
    {
        $this->accepted = $accepted;
    }

    /**
     * @return mixed
     */
    public function getRole()
    {
        return $this->role;
    }

    /**
     * @param mixed $role
     */
    public function setRole($role)
    {
        $this->role = $role;
    }

    /**
     * @return mixed
     */
    public function getJoindate()
    {
        return $this->joindate;
    }

    /**
     * @param mixed $joindate
     */
    public function setJoindate($joindate)
    {
        $this->joindate = $joindate;
    }


}