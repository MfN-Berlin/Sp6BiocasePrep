SELECT T1.`GUID`             AS `_unitguid`,
	   T2.`GUID`             AS `_datasetguid`,
       T3.`GUID`             AS `_collectingeventguid`,
       T4.`GUID`             AS `_localityguid`,
       T4.`Datum`            AS `loc_Datum`,
       T4.`Lat1Text`         AS `loc_Lat1Text`,
       T4.`Lat2Text`         AS `loc_Lat2Text`,
       T4.`LatLongAccuracy`  AS `loc_LatLongAccuracy`,
       CASE 
         WHEN T4.`LatLongAccuracy` = NULL
         THEN NULL
         ELSE T4.`LatLongAccuracy` * 40000000/360/2  
         END                 AS `CoordinateErrorDistanceInMeters `,
       T4.`LatLongMethod`    AS `CoordinateMethod`,
       T4.`LatLongType`      AS `loc_LatLongType`,
       T4.`Latitude1`        AS `LatitudeDecimal1`,
       T4.`Latitude2`        AS `LatitudeDecimal2`,
       T4.`Long1Text`        AS `loc_Long1Text`,
       T4.`Long2Text`        AS `loc_Long2Text`,
       T4.`Longitude1`       AS `LongitudeDecimal1`,
       T4.`Longitude2`       AS `LongitudeDecimal2`,
       T4.`SrcLatLongUnit`   AS `loc_SrcLatLongUnit`,
       T5.`UtmDatum`         AS `UTMDatum`,
       T5.`UtmEasting`       AS `UTMEasting`,
       T5.`UtmFalseEasting`  AS `locd_UtmFalseEasting`,
       T5.`UtmNorthing`      AS `UtMNorthing`,
       T5.`UtmFalseNorthing` AS `locd_UtmFalseNorthing`,
       T5.`UtmOrigLatitude`  AS `locd_UtmOrigLatitude`,
       T5.`UtmOrigLongitude` AS `locd_UtmOrigLongitude`,
       T5.`UtmScale`         AS `locd_UtmScale`,
       T5.`UtmZone`          AS `UTMZone`
  FROM `specify_publication`.`collectionobject`     T1
       INNER JOIN `specify_publication`.`collection`      T2 ON T1.`CollectionID`      = T2.`CollectionID`
       INNER JOIN `specify_publication`.`collectingevent` T3 ON T1.`CollectingEventID` = T3.`CollectingEventID`
       LEFT JOIN  `specify_publication`.`locality`        T4 ON T3.`LocalityID`        = T4.`LocalityID` 
       LEFT JOIN  `specify_publication`.`localitydetail`  T5 ON T4.`LocalityID`        = T5.`LocalityID` 
 WHERE T2.`Code`='ZMB_Aves';