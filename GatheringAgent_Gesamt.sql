SELECT CONCAT(CONCAT(COALESCE(NULLIF(`FirstName`,''),' '),'') 
                 ,CONCAT(COALESCE(NULLIF(`MiddleInitial`,''),' '),'') 
                 ,`LastName`) AS `FullName`, 
T1.`IsPrimary`, T1.`OrderNumber`, T1.`Remarks`,
T5.`CollectionName`, T4.`CatalogNumber` 
FROM `specify_demo`.`collector` T1
INNER JOIN `specify_demo`.`agent` T2
ON T1.`AgentID`= T2.`AgentID`
INNER JOIN `specify_demo`.`collectingevent` T3
ON T1.`CollectingeventID`= T3.`CollectingeventID`
INNER JOIN `specify_demo`.`collectionobject` T4
ON T3.`CollectingeventID`= T4.`CollectingeventID`
INNER JOIN `specify_demo`.`collection` T5
ON T4.`CollectionID`= T5.`CollectionID`
Limit 100000