SELECT 
     SUBSTRING_INDEX(GROUP_CONCAT(CumulusID SEPARATOR ','),',',1) AS CumulusID,
     GROUP_CONCAT(CumulusID SEPARATOR ',') AS CumulusIDListe, 
     SUBSTRING_INDEX(T1.`CumulusAssetName`,'.',1) AS `GIN`,
     T1.`CumulusAssetName` AS `CumulusAssetName`,
     T2.`fmt` AS `fmt`

FROM `mfn_cumulus`.`t_cumulusasset` T1 
INNER JOIN (SELECT 1 as ID, 'jpg' as `fmt`
			UNION ALL
            SELECT 2 as ID, 'tif' as `fmt`
			UNION ALL
            SELECT 3 as ID, 'dng' as `fmt`) as T2
ON RIGHT(T1.CumulusAssetName, 3) = T2.`fmt`
WHERE T1.`CumulusAssetName` like 'ZMB_Aves%' OR T1.`CumulusAssetName` IS NOT NULL
GROUP BY SUBSTRING_INDEX(T1.`CumulusAssetName`,'.',1)
ORDER BY SUBSTRING_INDEX(T1.`CumulusAssetName`,'.',1), T2.ID