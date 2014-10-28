   SELECT T1.`GeographyTreeDefID`,
          T1.`GeographyID`,
          T1.`ParentID`,
          T1.`RankID`,
          CASE
            WHEN (T1.`RankID` = 400)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 400)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 400)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 400)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 400)
            THEN T5.`Name`
            ELSE ''
          END AS `County`,
          CASE
            WHEN (T1.`RankID` = 400)
            THEN T1.`GeographyID`
            WHEN (T2.`RankID` = 400)
            THEN T2.`GeographyID`
            WHEN (T3.`RankID` = 400)
            THEN T3.`GeographyID`
            WHEN (T4.`RankID` = 400)
            THEN T4.`GeographyID`
            WHEN (T5.`RankID` = 400)
            THEN T5.`GeographyID`
            ELSE NULL
          END AS `CountyID`,
          CASE
            WHEN (T1.`RankID` = 300)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 300)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 300)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 300)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 300)
            THEN T5.`Name`
            ELSE ''
          END AS `State`,
          CASE
            WHEN (T1.`RankID` = 300)
            THEN T1.`GeographyID`
            WHEN (T2.`RankID` = 300)
            THEN T2.`GeographyID`
            WHEN (T3.`RankID` = 300)
            THEN T3.`GeographyID`
            WHEN (T4.`RankID` = 300)
            THEN T4.`GeographyID`
            WHEN (T5.`RankID` = 300)
            THEN T5.`GeographyID`
            ELSE NULL
          END AS `StateID`,
          CASE
            WHEN (T1.`RankID` = 200)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 200)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 200)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 200)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 200)
            THEN T5.`Name`
            ELSE ''
          END AS `Country`,
          CASE
            WHEN (T1.`RankID` = 200)
            THEN T1.`GeographyID`
            WHEN (T2.`RankID` = 200)
            THEN T2.`GeographyID`
            WHEN (T3.`RankID` = 200)
            THEN T3.`GeographyID`
            WHEN (T4.`RankID` = 200)
            THEN T4.`GeographyID`
            WHEN (T5.`RankID` = 200)
            THEN T5.`GeographyID`
            ELSE NULL
          END AS `CountryID`,
          CASE
            WHEN (T1.`RankID` = 100)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 100)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 100)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 100)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 100)
            THEN T5.`Name`
            ELSE ''
          END AS `Continent`,
          CASE
            WHEN (T1.`RankID` = 100)
            THEN T1.`GeographyID`
            WHEN (T2.`RankID` = 100)
            THEN T2.`GeographyID`
            WHEN (T3.`RankID` = 100)
            THEN T3.`GeographyID`
            WHEN (T4.`RankID` = 100)
            THEN T4.`GeographyID`
            WHEN (T5.`RankID` = 100)
            THEN T5.`GeographyID`
            ELSE NULL
          END AS `ContinentID`,
          CASE
            WHEN (T1.`RankID` = 0)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 0)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 0)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 0)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 0)
            THEN T5.`Name`
            ELSE ''
          END AS `Earth`,
          CASE
            WHEN (T1.`RankID` = 0)
            THEN T1.`GeographyID`
            WHEN (T2.`RankID` = 0)
            THEN T2.`GeographyID`
            WHEN (T3.`RankID` = 0)
            THEN T3.`GeographyID`
            WHEN (T4.`RankID` = 0)
            THEN T4.`GeographyID`
            WHEN (T5.`RankID` = 0)
            THEN T5.`GeographyID`
            ELSE NULL
          END AS `EarthID`


     FROM `specify_publication`.`geography` T1
          LEFT OUTER JOIN `specify_publication`.`geography` T2  ON (T1.`GeographyTreeDefID`  = T2.`GeographyTreeDefID`  AND T1.`ParentID`  =  T2.`GeographyID`)
          LEFT OUTER JOIN `specify_publication`.`geography` T3  ON (T2.`GeographyTreeDefID`  = T3.`GeographyTreeDefID`  AND T2.`ParentID`  =  T3.`GeographyID`)
          LEFT OUTER JOIN `specify_publication`.`geography` T4  ON (T3.`GeographyTreeDefID`  = T4.`GeographyTreeDefID`  AND T3.`ParentID`  =  T4.`GeographyID`)
          LEFT OUTER JOIN `specify_publication`.`geography` T5  ON (T4.`GeographyTreeDefID`  = T5.`GeographyTreeDefID`  AND T4.`ParentID`  =  T5.`GeographyID`)
