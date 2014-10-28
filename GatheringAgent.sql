    SELECT T1.`AgentID`, 
           CONCAT(
               IFNULL(
                   NULLIF(
					   CONCAT(IFNULL(`FirstName`,''),' '),
                   ''),
               ''),
               IFNULL(
                   NULLIF(
					   CONCAT(IFNULL(`MiddleInitial`,''),' '),
                   ''),
               ''),
               T1.`LastName`
           )                      AS FullName
      FROM `specify_demo`.`agent` AS T1
