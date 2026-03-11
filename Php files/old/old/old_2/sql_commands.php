<?php
class SqlCommand{
    // ---------- <Variables>  -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

    // ---------- <Constructor> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __Construct(){}

    // ---------- <SQL Scripts> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function select_tabletLista()                        {return "SELECT * FROM [dbo].[tablet_lista] WHERE [eszkoz_id] = :eszkoz_id";}
    public function select_tabletNapiMunkalapok()               {return "SELECT * FROM [dbo].[TabletNapiMunkalapok] (:eszkoz_id, :datum)";}
    public function select_verzioAutogumiPlaza()                {return "SELECT [verzio_autogumi_plaza] FROM [dbo].[Parameters]";}
    public function select_tabletMunkalapSzezonalisReszletezo() {return "SELECT * FROM [local].[Tablet_Munkalap_szezonalis_reszletezo] (:foglalas_id)";}
    public function exec_tabletFelvitele()                      {return "EXEC [dbo].[TabletFelvitele] :eszkoz_id";}
    public function exec_bizonylatKepPozicioFelvitele()         {return "EXEC [dbo].[BizonylatKepPozicioFelvitele] :parameter";}
    public function exec_bizonylatKepFelvitele()                {return "EXEC [dbo].[BizonylatDokumentumFelvitele] :parameter";}
    public function exec_bizonylatID_SQL()                      {return "SELECT id FROM [dbo].[Bizonylat] WHERE parent_id=:id";}
    public function exec_tabletMunkalapSzezonalisFelvitele()    {return "EXEC [local].[Tablet_MunkalapSzezonalisFelvitele] :foglalas_id, :output";}
}