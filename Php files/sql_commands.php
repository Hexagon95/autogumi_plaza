<?php
class SqlCommand{
    // ---------- <Variables>  -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

    // ---------- <Constructor> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __Construct(){}

    // ---------- <SQL Scripts> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function select_tabletMunkalapSzezonalisReszletezo() {return "SELECT * FROM [local].[Tablet_Munkalap_szezonalis_reszletezo] (:eszkoz_id, :datum, :foglalas_id)";}
    public function select_tabletMunkalapEsetiReszletezo()      {return "SELECT * FROM [local].[Tablet_Munkalap_eseti_reszletezo] (:eszkoz_id, :datum, :foglalas_id)";}
    public function select_tabletAbroncsIgenylesReszletezo()    {return "SELECT * FROM [local].[Tablet_Abroncs_igenyles_reszletezo] (:eszkoz_id, :datum, :foglalas_id)";}
    public function select_tabletNaptarMunkalapok()             {return "SELECT * FROM [local].[Tablet_Naptar_munkalapok] (:eszkoz_id, :datum_tol, :datum_ig)";}
    public function select_tabletNaptarRendszamKereso()         {return "SELECT * FROM [local].[Tablet_Naptar_Rendszam_kereso] (:eszkoz_id, :plate_number)";}
    public function select_tabletLista()                        {return "SELECT * FROM [dbo].[tablet_lista] WHERE [eszkoz_id] = :eszkoz_id";}
    public function select_tabletNapiMunkalapok()               {return "SELECT * FROM [dbo].[TabletNapiMunkalapok] (:eszkoz_id, :datum)";}
    public function exec_bizonylatID_SQL()                      {return "SELECT id FROM [dbo].[Bizonylat] WHERE parent_id=:id";}
    public function select_verzioAutogumiPlaza()                {return "SELECT [verzio_autogumi_plaza] FROM [dbo].[Parameters]";}
    public function select_MunkalapSzezonalisPozicioKepek()     {return "SELECT [dbo].[Munkalap_szezonalis_pozicio_kepek] (:foglalas_id, :pozicio)";}
    public function select_MunkalapEsetiPozicioKepek()          {return "SELECT [dbo].[Munkalap_eseti_pozicio_kepek] (:foglalas_id, :pozicio)";}
    public function exec_tabletFelvitele()                      {return "EXEC [dbo].[TabletFelvitele] :eszkoz_id";}
    public function exec_bizonylatKepPozicioFelvitele()         {return "EXEC [dbo].[BizonylatKepPozicioFelvitele] :parameter";}
    public function exec_bizonylatKepFelvitele()                {return "EXEC [dbo].[BizonylatDokumentumFelvitele] :parameter";}
    public function exec_tabletEsetiFelvitele()                 {return "EXEC [dbo].[Tablet_EsetiFelvitele] :parameter, :user_id, :lezart, :output";}
    public function exec_tabletSzezonalisFelvitele()            {return "EXEC [dbo].[Tablet_SzezonalisFelvitele] :parameter, :user_id, :lezart, :output";}
    public function exec_tabletAbroncsigenylesFelvitele()       {return "EXEC [dbo].[Tablet_AbroncsigenylesFelvitele] :parameter, :lezart, :output";}
    public function exec_tabletMunkalapMeghiusulas()            {return "EXEC [local].[Tablet_MunkalapMeghiusulas] :foglalas_id, :indoklas, :output";}
    public function exec_tabletMunkalapEsetiMeghiusulas()       {return "EXEC [local].[Tablet_MunkalapEsetiMeghiusulas] :foglalas_id, :indoklas, :output";}
    public function exec_tabletMunkalapSzezonalisFelvitele()    {return "EXEC [local].[Tablet_MunkalapSzezonalisFelvitele] :foglalas_id, :output";}
    public function exec_tabletBelep()                          {return "EXEC [mosaic].[dbo].[TabletBelep] :eszkoz_id, :verzio";}
}