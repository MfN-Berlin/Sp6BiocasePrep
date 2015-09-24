	SELECT T1.`Guid`                       		AS `_datasetguid`,			
           COALESCE(T6.`SourceInstitutionID`,
					T2.`Code`)					AS `SourceInstitutionID`,    
           COALESCE(T6.`SourceID`,
					T1.`Code`)					AS `SourceID`,               
           COALESCE(T6.`DateModified`, 
					T1.`TimestampModified`)		AS `DateModified`,
           COALESCE(T6.`DatasetTitle`, 
					T1.`CollectionName`)		AS `DatasetTitle`,
           COALESCE(T6.`DatasetDetails`,
					T1.`Description`)			AS `DatasetDetails`,
           COALESCE(T6.`DatasetCoverage`,
					T1.`Scope`)          		AS `DatasetCoverage`,
           COALESCE(T6.`DatasetURI`, 
					T1.`WebSiteURI`)        	AS `DatasetURI`,
           CONCAT(T2.Name,' ',T5.`Address`,' ',T5.`PostalCode`, ' ',T5.`City`,' ',T5.`Country`) AS `ContentContactAddress`,			
           CONCAT(T2.Name,' ',T5.`Address`,' ',T5.`PostalCode`, ' ',T5.`City`,' ',T5.`Country`) AS `TechnicalContactAddress`,			
		   COALESCE(T6.`ContentContactName`,
		   (SELECT 
				T6.`FullName` 
			  FROM `specify_biocasepreparer2`.`v_imp_agent` T6 
					INNER JOIN `specify`.`agent` T7 		ON T6.`AgentID` 	= T7.`AgentID`
			 WHERE T7.`CollectionCCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))							AS `ContentContactName`,
		   COALESCE(T6.`ContentContactEmail`,
		   (SELECT 
				T7.`Email` 
			  FROM `specify_biocasepreparer2`.`v_imp_agent` T6 
					INNER JOIN `specify`.`agent` T7 		ON T6.`AgentID` 	= T7.`AgentID`
			 WHERE T7.`CollectionCCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))							AS `ContentContactEmail`,
		   COALESCE(T6.`ContentContactPhone`,
		   (SELECT 
				T8.`Phone1` 
			  FROM `specify_biocasepreparer2`.`v_imp_agent` T6 
					INNER JOIN `specify`.`agent` T7 		ON T6.`AgentID` 	= T7.`AgentID`
					INNER JOIN `specify`.`address` T8 		ON T7.`AgentID` 	= T8.`AgentID`
			 WHERE T7.`CollectionCCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))							AS `ContentContactPhone`,
		   COALESCE(T6.`TechnicalContactName`,
		   (SELECT 
				T6.`FullName` 
			  FROM `specify_biocasepreparer2`.`v_imp_agent` T6 
					INNER JOIN `specify`.`agent` T7 		ON T6.`AgentID` 	= T7.`AgentID`
			 WHERE T7.`CollectionTCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))							AS `TechnicalContactName`,
		   COALESCE(T6.`TechnicalContactEmail`,
		   (SELECT 
				T7.`Email` 
			  FROM `specify_biocasepreparer2`.`v_imp_agent` T6 
					INNER JOIN `specify`.`agent` T7 		ON T6.`AgentID` 	= T7.`AgentID`
			 WHERE T7.`CollectionTCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))							AS `TechnicalContactEmail`,
		   COALESCE(T6.`TechnicalContactPhone`,
		   (SELECT 
				T8.`Phone1` 
			  FROM `specify_biocasepreparer2`.`v_imp_agent` T6 
					INNER JOIN `specify`.`agent` T7 		ON T6.`AgentID` 	= T7.`AgentID`
					INNER JOIN `specify`.`address` T8 		ON T7.`AgentID` 	= T8.`AgentID`
			 WHERE T7.`CollectionTCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))							AS `TechnicalContactPhone`,
		   COALESCE(T6.`RecordBasis`,
		   (SELECT
				T6.`Description`
			  FROM `specify`.`collectionobject` T6
			 WHERE T6.`CollectionID` = T1.`CollectionID` 
			 LIMIT 1)) 							AS `RecordBasis`,
		   T6.`OtherProviderUDDI`				AS `OtherProviderUDDI`,
		   T6.`IPRText` 						AS `IPRText`,
		   T6.`IPRDetails` 						AS `IPRDetails`,
		   T6.`IPRURI` 							AS `IPRURI`,
		   T6.`CopyrightText` 					AS `CopyrightText`,
		   T6.`CopyrightDetails` 				AS `CopyrightDetails`,
		   T6.`CopyrightURI` 					AS `CopyrightURI`,
		   T6.`TermsOfUseText` 					AS `TermsOfUseText`,
		   T6.`TermsOfUseDetails` 				AS `TermsOfUseDetails`,
		   T6.`TermsOfUseURI` 					AS `TermsOfUseURI`,
		   T6.`DisclaimersText` 				AS `DisclaimersText`,
		   T6.`DisclaimersDetails` 				AS `DisclaimersDetails`,
		   T6.`DisclaimersURI` 					AS `DisclaimersURI`,
		   T6.`LicenseText` 					AS `LicenseText`,
		   T6.`LicenseDetails` 					AS `LicenseDetails`,
		   T6.`LicenseURI` 						AS `LicenseURI`,
		   T6.`AcknowledgementsText` 			AS `AcknowledgementsText`,
		   T6.`AcknowledgementsDetails` 		AS `AcknowledgementsDetails`,
		   T6.`AcknowledgementsURI` 			AS `AcknowledgementsURI`,
		   T6.`CitationsText` 					AS `CitationsText`,
		   T6.`CitationsDetails` 				AS `CitationsDetails`,
		   T6.`CitationsURI` 					AS `CitationsURI`
	  FROM `specify`.`institution` T2 
		   INNER JOIN `specify`.`division` T3 				ON T2.`InstitutionID` 	= T3.`InstitutionID`
		   INNER JOIN `specify`.`discipline` T4 			ON T3.`DivisionID` 		= T4.`DivisionID`
		   INNER JOIN `specify`.`collection` T1 			ON T4.`DisciplineID` 	= T1.`DisciplineID`
		   INNER JOIN `specify`.`address` T5 				ON T2.`AddressID` 		= T5.`AddressID`,
		   `specify_biocasepreparer2`.`t_metadata_template` T6
	 WHERE T1.`Code` 				= 'MB_ED'
	   AND T6.`MetadataTemplateID` 	= 'EB'
