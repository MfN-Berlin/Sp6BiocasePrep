SELECT T1.`GUID`                  AS `_unitguid`,
       T2.`GUID`                  AS `_collectingeventguid`,
       T2.`VerbatimDate`          AS `DateText`,
       T2.`StartDate`             AS `ISODateTimeBegin`,
       T2.`EndDate`               AS `ISODateTimeEnd`,
       T2.`StartTime`             AS `TimeOfDayBegin`,     
       T2.`EndTime`               AS `TimeOfDayEnd`,
       T2.`Remarks`               AS `Notes`,
       T2.`Method`                AS `Method`,
       T2.`VerbatimLocality`      AS `LocalityText`,
       T2.`Version`               AS `cev_Version`, 
       T2.`EndDatePrecision`      AS `cev_EndDatePrecision`, 
       T2.`EndDateVerbatim`       AS `cev_EndDateVerbatim`, 
       T2.`StartDatePrecision`    AS `cev_StartDatePrecision`,
       T2.`StartDateVerbatim`     AS `cev_StartDateVerbatim`,
       T2.`StationFieldNumber`    AS `cev_StationFieldNumber`,
       T2.`Visibility`            AS `cev_Visibility`,
       T3.`Version`               AS `loc_Version`,
       T3.`Datum`                 AS `MeasurementDateTime`,
       T3.`ElevationAccuracy`     AS `Altitude_Accuracy`,
       T3.`ElevationMethod`       AS `Altitude_Method`,
       T3.`GML`                   AS `GML`,
       T3.`GUID`                  AS `_localityguid`,
       T3.`LocalityName`          AS `AreaDetail`,
       T3.`MaxElevation`          AS `Altitude_UpperValue`,
       T3.`MinElevation`          AS `Altitude_LowerValue`,
       T3.`NamedPlace`            AS `NearNamedPlace`,
       T3.`RelationToNamedPlace`  AS `NearNamedPlaceRelationTo`,
       T3.`OriginalElevationUnit` AS `Altitude_UnitOfMeasurement`,
       T3.`OriginalLatLongUnit`   AS `loc_OriginalLatLongUnit`,
       T3.`Remarks`               AS `Altitude_MeasurementOrFactText`,
       T3.`ShortName`             AS `loc_ShortName`,
       T3.`Text1`                 AS `loc_Text1`,
       T3.`Text2`                 AS `loc_Text2`,
       T3.`VerbatimElevation`     AS `loc_VerbatimElevation`,
       'Altitude'                 AS `Altitude_Parameter`,
       NULL                       AS `NearNamedPlace_Language`,
       NULL                       AS `NearNamedPlaceRelationTo_Language`,
       T5.`AreaName`              AS `Country`,
       'EN'                       AS `Country_Language`,
       NULL                       AS `NameDerived`, 
       NULL                       AS `NameDerived_Language`, 
       NULL                       AS `ISO3166Code` 

FROM `specify_publication`.`collectionobject`      T1
INNER JOIN `specify_publication`.`collectingevent` T2 ON T1.`CollectingEventID` = T2.`CollectingEventID`
LEFT  JOIN `specify_publication`.`locality`        T3 ON T2.`LocalityID`        = T3.`LocalityID`
INNER JOIN `specify_publication`.`collection`      T4 ON T1.`CollectionID`      = T4.`CollectionID`
LEFT  JOIN `t_tmp_biocase_gathering_namedareas`    T5 ON T1.`GUID`              = T5.`_unitguid`
WHERE T4.`Code` = 'ZMB_Aves'
AND   (T5.`AreaClass` = 'country' OR T5.`AreaClass` = NULL)