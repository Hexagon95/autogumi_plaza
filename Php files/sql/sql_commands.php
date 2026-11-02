<?php

class SqlCommand{
    // ---------- <SQL Scripts> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function select_tabletMunkalapSzezonalisReszletezo(): string {return "SELECT * FROM [local].[Tablet_Munkalap_szezonalis_reszletezo] (:eszkoz_id, :datum, :foglalas_id)";}
    public function select_tabletMunkalapEsetiReszletezo(): string      {return "SELECT * FROM [local].[Tablet_Munkalap_eseti_reszletezo] (:eszkoz_id, :datum, :foglalas_id, :parent_id, :user_id)";}
    public function select_tabletAbroncsIgenylesReszletezo(): string    {return "SELECT * FROM [local].[Tablet_Abroncs_igenyles_reszletezo] (:eszkoz_id, :munkalap_id, :datum, :foglalas_id)";}
    public function select_tabletNaptarMunkalapok(): string             {return "SELECT * FROM [local].[Tablet_Naptar_munkalapok] (:eszkoz_id, :datum_tol, :datum_ig)";}
    public function select_tabletNaptarRendszamKereso(): string         {return "SELECT * FROM [local].[Tablet_Naptar_Rendszam_kereso] (:eszkoz_id, :plate_number)";}
    public function select_tabletLista(): string                        {return "SELECT * FROM [dbo].[tablet_lista] WHERE [eszkoz_id] = :eszkoz_id";}
    public function select_tabletNapiMunkalapok(): string               {return "SELECT * FROM [dbo].[TabletNapiMunkalapok] (:eszkoz_id, :datum)";}
    public function select_askEsetiMunkalapMeghiusulasOkai(): string    {return "SELECT * FROM [dbo].[Eseti_munkalap_meghiusulas_okai] ()";}
    public function exec_bizonylatID_SQL(): string                      {return "SELECT id FROM [dbo].[Bizonylat] WHERE parent_id=:id";}
    public function select_verzioAutogumiPlaza(): string                {return "SELECT [verzio_autogumi_plaza] FROM [dbo].[Parameters]";}
    public function select_MunkalapSzezonalisPozicioKepek(): string     {return "SELECT [dbo].[Munkalap_szezonalis_pozicio_kepek] (:foglalas_id, :pozicio)";}
    public function select_MunkalapEsetiPozicioKepek(): string          {return "SELECT [dbo].[Munkalap_eseti_pozicio_kepek] (:foglalas_id, :pozicio)";}
    public function select_tabletDashboardPanels(): string              {return "SELECT [dbo].[Tablet_Dashboard_panels] (:user_id)";}
    public function exec_tabletFelhasznaloAdatok(): string              {return "EXEC [dbo].[Tablet_FelhasznaloAdatok] :eszkoz_id, :user_name, :user_password";}
    public function exec_tabletFelhasznaloAdatokNew(): string           {return "EXEC [dbo].[Tablet_FelhasznaloAdatok_new] :eszkoz_id, :user_name, :user_password";}
    public function exec_tabletFelvitele(): string                      {return "EXEC [dbo].[TabletFelvitele] :eszkoz_id";}
    public function exec_bizonylatKepPozicioFelvitele(): string         {return "EXEC [dbo].[BizonylatKepPozicioFelvitele] :parameter, :user_id";}
    public function exec_bizonylatKepFelvitele(): string                {return "EXEC [dbo].[BizonylatDokumentumFelvitele] :parameter, :user_id";}
    public function exec_bizonylatAlairasFelvitele(): string            {return "EXEC [dbo].[BizonylatAlairasFelvitele] :parameters";}
    public function exec_tabletEsetiFelvitele(): string                 {return "EXEC [dbo].[Tablet_EsetiFelvitele] :parameter, :user_id, :lezart, :output";}
    public function exec_tabletSzezonalisFelvitele(): string            {return "EXEC [dbo].[Tablet_SzezonalisFelvitele] :parameter, :user_id, :lezart, :output";}
    public function exec_tabletAbroncsigenylesFelvitele(): string       {return "EXEC [dbo].[Tablet_AbroncsigenylesFelvitele] :parameter, :user_id, :lezart, :output";}
    public function exec_tabletMunkalapMeghiusulas(): string            {return "EXEC [local].[Tablet_MunkalapMeghiusulas] :foglalas_id, :indoklas, :user_id, :output";}
    public function exec_tabletMunkalapEsetiMeghiusulas(): string       {return "EXEC [local].[Tablet_MunkalapEsetiMeghiusulas] :foglalas_id, :indoklas, :user_id, :output";}
    public function exec_tabletIgenylesMeghiusulas(): string            {return "EXEC [local].[Tablet_IgenylesMeghiusulas] :bizonylat_id, :indoklas, :user_id, :output";}
    public function exec_tabletMunkalapSzezonalisFelvitele(): string    {return "EXEC [local].[Tablet_MunkalapSzezonalisFelvitele] :foglalas_id, :user_id, :output";}
    public function exec_tabletBelep(): string                          {return "EXEC [mosaic].[dbo].[TabletBelep] :eszkoz_id, :verzio";}
    public function exec_bizonylatStatuszUpdate(): string               {return "EXEC [dbo].[BizonylatStatuszUpdate] :bizonylat_id, :statusz_id, :user_id";}
}