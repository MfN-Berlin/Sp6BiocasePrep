DELIMITER GO 

CREATE DATABASE IF NOT EXISTS `specify_biocase`;

GO

USE `specify_biocase`;

GO

DROP TABLE IF EXISTS `t_biocase_unit`;

GO

CREATE TABLE IF NOT EXISTS `t_biocase_unit`
(
  `_datasetguid`          				VARCHAR(36)   NOT NULL,
  `_unitguid`             				VARCHAR(36)   NOT NULL,
  `SourceInstitutionID`   				VARCHAR(128)  NOT NULL,
  `SourceID`              				VARCHAR(128)  NOT NULL,
  `UnitID`                				VARCHAR(128)  NOT NULL,
  `UnitIDNumeric`         				INT           NULL,
  `LastEditor`            				VARCHAR(128)  NULL,
  `DateLastEdited`        				DATETIME      NULL,
  `RecordBasis`           				VARCHAR(128)  NULL,
  `CollectorsFieldNumber` 				VARCHAR(128)  NULL,
  `Sex`                   				VARCHAR(128)  NULL,
  `Age`                   				VARCHAR(128)  NULL,
  `RecordURI`             				VARCHAR(1024) NULL,
  `Notes`                 				TEXT          NULL,

  CONSTRAINT `pk_biocase_unit_01` PRIMARY KEY (`_unitguid`),
  CONSTRAINT `uq_biocase_unit_01` UNIQUE (`SourceInstitutionID`, `SourceID`, `UnitID`),

  KEY `ix_biocase_unit_01` (`_datasetguid`, `_unitguid`),
  KEY `ix_biocase_unit_02` (`UnitID`, `_unitguid`),
  KEY `ix_biocase_unit_03` (`DateLastEdited`, `_unitguid`),
  KEY `ix_biocase_unit_04` (`_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_biocase_gathering`;

GO

CREATE TABLE IF NOT EXISTS `t_biocase_gathering`
(
  `_datasetguid`          				VARCHAR(36)   NOT NULL,
  `_unitguid`             				VARCHAR(36)   NOT NULL,
  `Gath_Altid_Accuracy`  				VARCHAR(128)  NULL,
  `Gath_Altid_IsQuantitative`  			VARCHAR(5)    NULL,
  `Gath_Altid_LowerValue`  				VARCHAR(128)  NULL,
  `Gath_Altid_DateTime`  				VARCHAR(128)  NULL,
  `Gath_Altid_Method`  					VARCHAR(255)  NULL,
  `Gath_Altid_Parameter`  				VARCHAR(255)  NULL,
  `Gath_Altid_UnitOfMeasurement`  		VARCHAR(255)  NULL,
  `Gath_Altid_UpperValue`  				VARCHAR(128)  NULL,
  `Gath_Altid_MOFText`  				TEXT          NULL,
  `Gath_AreaDetail`  	  				TEXT          NULL,
  `Gath_Code`	      	  				VARCHAR(128)  NULL,
  `Gath_Country_Name`	      			VARCHAR(128)  NULL,
  `Gath_Country_Name_Language` 			VARCHAR(128)  NULL,
  `Gath_Country_NameDerived`   			VARCHAR(128)  NULL,
  `Gath_Country_NameDerived_Language` 	VARCHAR(128)  NULL,
  `Gath_Country_ISO`	      			VARCHAR(4)    NULL,
  `Gath_DateTime_Text`    				VARCHAR(128)  NULL,
  `Gath_DateTime_Begin`   				DATETIME      NULL,
  `Gath_DateTime_End`     				DATETIME      NULL,
  `Gath_DateTime_TimeZone`				VARCHAR(128)  NULL,
  `Gath_Depth_Accuracy`  				VARCHAR(128)  NULL,
  `Gath_Depth_IsQuantitative`  			VARCHAR(5)    NULL,
  `Gath_Depth_LowerValue`  				VARCHAR(128)  NULL,
  `Gath_Depth_DateTime`  				VARCHAR(128)  NULL,
  `Gath_Depth_Method`  					VARCHAR(255)  NULL,
  `Gath_Depth_Parameter`  				VARCHAR(255)  NULL,
  `Gath_Depth_UnitOfMeasurement`  		VARCHAR(255)  NULL,
  `Gath_Depth_UpperValue`  				VARCHAR(128)  NULL,
  `Gath_Depth_MOFText`  				TEXT          NULL,
  `Gath_GML`		      				TEXT          NULL,
  `Gath_LocalityText`     				TEXT          NULL,
  `Gath_Method`		      				TEXT          NULL,
  `Gath_Notes`       	  				TEXT          NULL,

  CONSTRAINT `pk_biocase_gathering 01` PRIMARY KEY (`_unitguid`),

  KEY `ix_biocase_gathering_01` (`_datasetguid`, `_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_biocase_identification`;

GO

CREATE TABLE IF NOT EXISTS `t_biocase_identification`
(
  `_unitguid`                              VARCHAR(36)  NOT NULL,
  `_identificationguid`                    VARCHAR(36)  NOT NULL,
  `_timestamp`                             DATETIME     NOT NULL,
  `ScientificName`                         VARCHAR(512) NOT NULL,
  `FullScientificNameString`               VARCHAR(512) NOT NULL,
  `GenusOrMonomial`                        VARCHAR(64)  NULL,
  `Subgenus`                               VARCHAR(64)  NULL,
  `SpeciesEpithet`                         VARCHAR(64)  NULL,
  `SubspeciesEpithet`                      VARCHAR(64)  NULL,
  `AuthorTeamOriginalAndYear`              VARCHAR(128) NULL,
  `AuthorTeamParenthesisAndYear`           VARCHAR(128) NULL,
  `CombinationAuthorTeamAndYear`           VARCHAR(128) NULL,
  `Breed`                                  VARCHAR(128) NULL,
  `NamedIndividual`                        VARCHAR(128) NULL,
  `IdentificationQualifier`                VARCHAR(64)  NULL,
  `IdentificationQualifier_insertionpoint` INT          NULL,
  `NameAddendum`                           VARCHAR(16)  NULL,
  `InformalNameString`                     VARCHAR(128) NULL,
  `InformalNameString_language`            VARCHAR(2)   NULL,
  `Code`                                   VARCHAR(128) NULL,
  `PreferredFlag`                          BIT          NULL,
  `NonFlag`                                BIT          NULL,
  `StoredUnderFlag`                        BIT          NULL,
  `ResultRole`                             VARCHAR(32)  NULL,
  `Date_DateText`                          VARCHAR(32)  NULL,
  `Date_TimeZone`                          VARCHAR(32)  NULL,
  `Date_ISODateTimeBegin`                  VARCHAR(32)  NULL,
  `Date_TimeOfDayBegin`                    VARCHAR(32)  NULL,
  `DayNumberBegin`                         INT          NULL,
  `Date_ISODateTimeEnd`                    VARCHAR(32)  NULL,
  `Date_TimeOfDayEnd`                      VARCHAR(32)  NULL,
  `Date_DayNumberEnd`                      INT          NULL,
  `PeriodExplicit`                         INT          NULL,
  `Method`                                 VARCHAR(64)  NULL,
  `Method_language`                        VARCHAR(2)   NULL,
  `Notes`                                  TEXT         NULL,
  `VerificationLevel`                      VARCHAR(64)  NULL,
  `IdentificationHistory`                  TEXT         NULL,

  CONSTRAINT `pk_biocase_unit_01` PRIMARY KEY (`_identificationguid`),

  KEY `ix_biocase_identification_01` (`_unitguid`,`_identificationguid`),
  KEY `ix_biocase_identification_02` (`ScientificName`,`_unitguid`),
  KEY `ix_biocase_identification_03` (`FullScientificNameString`,`_unitguid`),
  KEY `ix_biocase_identification_04` (`GenusOrMonomial`,`_unitguid`),
  KEY `ix_biocase_identification_05` (`Subgenus`,`_unitguid`),
  KEY `ix_biocase_identification_06` (`SpeciesEpithet`,`_unitguid`),
  KEY `ix_biocase_identification_07` (`SubspeciesEpithet`,`_unitguid`),
  KEY `ix_biocase_identification_08` (`_unitguid`)
)

GO

DROP TABLE IF EXISTS `t_biocase_identification_highertaxon`;

GO

CREATE TABLE IF NOT EXISTS `t_biocase_identification_highertaxon`
(
  `_identificationguid` VARCHAR(36)   NOT NULL,
  `HigherTaxonName`     VARCHAR(128)  NOT NULL,
  `HigherTaxonRank`     VARCHAR(16)   NOT NULL,
  
  CONSTRAINT `pk_biocase_identification_highertaxon_01` PRIMARY KEY (`_identificationguid`, `HigherTaxonRank`),

  KEY `ix_biocase_identification_highertaxon_01` (`HigherTaxonName`, `_identificationguid`),
  KEY `ix_biocase_identification_highertaxon_02` (`HigherTaxonRank`, `_identificationguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_biocase_specimenunit_mark`;

GO

CREATE TABLE IF NOT EXISTS `t_biocase_specimenunit_mark`
(
  `_datasetguid`              VARCHAR(36)  NOT NULL,
  `_unitguid`                 VARCHAR(36)  NOT NULL,
  `_markguid`                 VARCHAR(36)  NOT NULL,

  `MarkType`                  VARCHAR(128) NULL,
  `MarkType_language`         VARCHAR(128) NULL,
  `MarkText`                  TEXT         NULL,
  `MarkText_language`         VARCHAR(128) NULL,
  `PositionOnObject`          VARCHAR(255) NULL,
  `PositionOnObject_language` VARCHAR(128) NULL,
  `MarkAuthor`                VARCHAR(255) NULL,
  `MarkComment`               TEXT         NULL,
  `MarkComment_language`      VARCHAR(128) NULL,

  CONSTRAINT `pk_biocase_specimenunit_mark_01` PRIMARY KEY (`_datasetguid`, `_unitguid`, `_markguid`),
  CONSTRAINT `uq_biocase_specimenunit_mark_01` UNIQUE (`_markguid`),

  KEY `ix_biocase_specimenunit_mark_01` (`_unitguid`)
)

GO

DROP TABLE IF EXISTS `t_biocase_measurementsorfacts`;

GO

CREATE TABLE IF NOT EXISTS `t_biocase_measurementsorfacts`
(
  `_datasetguid`              VARCHAR(36)  NOT NULL,
  `_unitguid`                 VARCHAR(36)  NOT NULL,
  `_mofguid`                  VARCHAR(36)  NOT NULL,

  `ABCDConcept`               VARCHAR(255) NULL,
  `Accuracy`                  VARCHAR(128) NULL,
  `AppliesTo`         		  VARCHAR(128) NULL,
  `AppliesTo_Language` 		  VARCHAR(128) NULL,
  `Duration`                  VARCHAR(128) NULL,
  `IsQuantitative`            VARCHAR(5)   NULL,
  `LowerValue`                VARCHAR(128) NULL,
  `LowerValue_Language`       VARCHAR(128) NULL,
  `MeasurementDateTime`       VARCHAR(128) NULL,
  `CitationDetail`			  TEXT         NULL,
  `TitleCitation`			  VARCHAR(128) NULL,
  `URI`      		          VARCHAR(255) NULL,
  `Method`  	              TEXT         NULL,
  `Method_Language`      	  VARCHAR(128) NULL,
  `Parameter`      	  		  VARCHAR(255) NULL,
  `Parameter_Language`        VARCHAR(128) NULL,
  `UnitOfMeasurement`      	  VARCHAR(128) NULL,
  `UpperValue`                VARCHAR(128) NULL,
  `UpperValue_Language`    	  VARCHAR(128) NULL,
  `MOFText`	                  TEXT         NULL,
  `MOFText_Language`      	  VARCHAR(128) NULL,

  CONSTRAINT `pk_biocase_measurementsorfacts_01` PRIMARY KEY (`_datasetguid`, `_unitguid`, `_mofguid`),
  CONSTRAINT `uq_biocase_measurementsorfacts_01` UNIQUE (`_mofguid`),

  KEY `ix_biocase_measurementsorfacts_01` (`_unitguid`)

)

GO

DROP TABLE IF EXISTS `t_biocase_metadata`;

GO

CREATE TABLE `t_biocase_metadata` (
  `_datasetguid`            varchar(36)   NOT NULL,
  `DatasetGUID`             varchar(255)  DEFAULT NULL,
  `TechnicalContactName`    varchar(255)  DEFAULT NULL,
  `TechnicalContactEmail`   varchar(255)  DEFAULT NULL,
  `TechnicalContactPhone`   varchar(255)  DEFAULT NULL,
  `TechnicalContactAddress` varchar(255)  DEFAULT NULL,
  `ContentContactName`      varchar(255)  DEFAULT NULL,
  `ContentContactEmail`     varchar(255)  DEFAULT NULL,
  `ContentContactPhone`     varchar(255)  DEFAULT NULL,
  `ContentContactAddress`   varchar(255)  DEFAULT NULL,
  `OtherProviderUDDI`       varchar(255)  DEFAULT NULL,
  `DatasetTitle`            varchar(255)  DEFAULT NULL,
  `DatasetDetails`          varchar(1024) DEFAULT NULL,
  `DatasetCoverage`         varchar(255)  DEFAULT NULL,
  `DatasetURI`              varchar(255)  DEFAULT NULL,
  `DatasetIconURI`          varchar(255)  DEFAULT NULL,
  `DatasetVersionMajor`     varchar(255)  DEFAULT NULL,
  `DatasetVersionMinor`     varchar(255)  DEFAULT NULL,
  `DatasetCreators`         varchar(255)  DEFAULT NULL,
  `DatasetContributors`     varchar(255)  DEFAULT NULL,
  `DateCreated`             varchar(255)  DEFAULT NULL,
  `DateModified`            varchar(255)  DEFAULT NULL,
  `OwnerOrganizationName`   varchar(255)  DEFAULT NULL,
  `OwnerOrganizationAbbrev` varchar(255)  DEFAULT NULL,
  `OwnerContactPerson`      varchar(255)  DEFAULT NULL,
  `OwnerContactRole`        varchar(255)  DEFAULT NULL,
  `OwnerAddress`            varchar(255)  DEFAULT NULL,
  `OwnerTelephone`          varchar(255)  DEFAULT NULL,
  `OwnerEmail`              varchar(255)  DEFAULT NULL,
  `OwnerURI`                varchar(255)  DEFAULT NULL,
  `OwnerLogoURI`            varchar(255)  DEFAULT NULL,
  `IPRText`                 varchar(255)  DEFAULT NULL,
  `IPRDetails`              varchar(1024) DEFAULT NULL,
  `IPRURI`                  varchar(255)  DEFAULT NULL,
  `CopyrightText`           varchar(255)  DEFAULT NULL,
  `CopyrightDetails`        varchar(1024) DEFAULT NULL,
  `CopyrightURI`            varchar(255)  DEFAULT NULL,
  `TermsOfUseText`          varchar(255)  DEFAULT NULL,
  `TermsOfUseDetails`       varchar(1024) DEFAULT NULL,
  `TermsOfUseURI`           varchar(255)  DEFAULT NULL,
  `DisclaimersText`         varchar(255)  DEFAULT NULL,
  `DisclaimersDetails`      varchar(1024) DEFAULT NULL,
  `DisclaimersURI`          varchar(255)  DEFAULT NULL,
  `LicenseText`             varchar(255)  DEFAULT NULL,
  `LicenseDetails`          varchar(1024) DEFAULT NULL,
  `LicenseURI`              varchar(255)  DEFAULT NULL,
  `AcknowledgementsText`    varchar(255)  DEFAULT NULL,
  `AcknowledgementsDetails` varchar(1024) DEFAULT NULL,
  `AcknowledgementsURI`     varchar(255)  DEFAULT NULL,
  `CitationsText`           varchar(255)  DEFAULT NULL,
  `CitationsDetails`        varchar(1024) DEFAULT NULL,
  `CitationsURI`            varchar(255)  DEFAULT NULL,
  `SourceInstitutionID`     varchar(255)  DEFAULT NULL,
  `SourceID`                varchar(255)  NOT NULL,
  `RecordBasis`             varchar(255)  DEFAULT NULL,
  `KindOfUnit`              varchar(255)  DEFAULT NULL,
  CONSTRAINT `pk_biocase_metadata_01` PRIMARY KEY (`SourceID`),
  CONSTRAINT `uq_biocase_metadata_01` UNIQUE (`_datasetguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Metadata for Biocase-Mapping';

GO

DROP TABLE IF EXISTS `t_biocase_multimediaobject`;

GO

CREATE TABLE `t_biocase_multimediaobject` (
  `_datasetguid`     varchar(36)   NOT NULL,
  `_unitguid`        varchar(36)   NOT NULL,
  `_mmoguid`         varchar(36)   NOT NULL,
  `CumulusID`        int(11)       NOT NULL,
  `UnitID`           varchar(45)   NOT NULL,
  `CumulusAssetName` varchar(255)  DEFAULT NULL,
  `Format`           varchar(45)   DEFAULT NULL,
  `FileURI`          varchar(255)  DEFAULT NULL,
  `ProductURI`       varchar(255)  DEFAULT NULL,
  `IPRText`          varchar(255)  DEFAULT NULL,
  `IPRDetails`       varchar(1024) DEFAULT NULL,
  `IPRURI`           varchar(255)  DEFAULT NULL,
  `LicenseText`      varchar(255)  DEFAULT NULL,
  `LicenseDetails`   varchar(1024) DEFAULT NULL,
  `LicenseURI`       varchar(255)  DEFAULT NULL,

  CONSTRAINT `pk_biocase_multimediaobject_01` PRIMARY KEY (`CumulusID`,`_unitguid`),
  CONSTRAINT `uq_biocase_multimediaobject_01` UNIQUE (`_mmoguid`),

  KEY `ix_biocase_multimediaobject_01` (`_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_biocase_gathering_namedareas`;

GO

CREATE TABLE  IF NOT EXISTS `t_biocase_gathering_namedareas` (
  `_datasetguid`       VARCHAR(36) NOT NULL,
  `_unitguid`          VARCHAR(36) NOT NULL,
  `_namedareasguid`    VARCHAR(36) NOT NULL,
  `Sequence`           int(4)      DEFAULT NULL,
  `AreaClass`          VARCHAR(64) DEFAULT NULL,
  `AreaClass_Language` VARCHAR(64) DEFAULT NULL,
  `AreaCode`           VARCHAR(64) DEFAULT NULL,
  `AreaCodeStandard`   VARCHAR(64) DEFAULT NULL,
  `AreaName`           VARCHAR(64) DEFAULT NULL,
  `AreaName_Language`  VARCHAR(64) DEFAULT NULL,
  `DataSource`         VARCHAR(64) DEFAULT NULL,

  CONSTRAINT `pk_biocase_gathering_namedareas_01` PRIMARY KEY (`AreaClass`,`_datasetguid`,`_unitguid`),
  CONSTRAINT `uq_biocase_gathering_namedareas_01` UNIQUE (`_namedareasguid`),

  KEY `ix_biocase_gathering_namedareas_01` (`_datasetguid`, `_unitguid`),
  KEY `ix_biocase_gathering_namedareas_02` (`_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

-- Günther Korb  04.11.2013

DROP TABLE IF EXISTS `t_biocase_gathering_nearnamedplaces`;

GO

CREATE TABLE  IF NOT EXISTS `t_biocase_gathering_nearnamedplaces` (
  `_datasetguid`                      VARCHAR(36) NOT NULL,
  `_unitguid`                         VARCHAR(36) NOT NULL,
  `_nearnamedplacesguid`              VARCHAR(36) NOT NULL,
  `NearNamedPlace`                    VARCHAR(64) DEFAULT NULL,
  `NearNamedPlace_Language`           VARCHAR(64) DEFAULT NULL,
  `NearNamedPlaceRelationTo`          VARCHAR(64) DEFAULT NULL,
  `NearNamedPlaceRelationTo_Language` VARCHAR(64) DEFAULT NULL,
  `DerivedFlag`                       INT         DEFAULT NULL,

  CONSTRAINT `pk_biocase_gathering_nearnamedplaces_01` PRIMARY KEY (`_nearnamedplacesguid`,`_datasetguid`,`_unitguid`),
  CONSTRAINT `uq_biocase_gathering_nearnamedplaces_01` UNIQUE (`_nearnamedplacesguid`),

  KEY `ix_biocase_gathering_nearnamedplaces_01` (`_datasetguid`, `_unitguid`),
  KEY `ix_biocase_gathering_nearnamedplaces_02` (`_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

-- Günther Korb  30.09.2013
-- 
DROP TABLE IF EXISTS `t_biocase_gathering`;

GO

CREATE TABLE `t_biocase_gathering` (
  `_datasetguid`                      VARCHAR(36)  NOT NULL,
  `_unitguid`                         VARCHAR(36)  NOT NULL,
  `Gath_Altid_Accuracy`               VARCHAR(128) DEFAULT NULL,
  `Gath_Altid_IsQuantitative`         VARCHAR(5)   DEFAULT NULL,
  `Gath_Altid_LowerValue`             VARCHAR(128) DEFAULT NULL,
  `Gath_Altid_DateTime`               VARCHAR(128) DEFAULT NULL,
  `Gath_Altid_Method`                 VARCHAR(255) DEFAULT NULL,
  `Gath_Altid_Parameter`              VARCHAR(255) DEFAULT NULL,
  `Gath_Altid_UnitOfMeasurement`      VARCHAR(255) DEFAULT NULL,
  `Gath_Altid_UpperValue`             VARCHAR(128) DEFAULT NULL,
  `Gath_Altid_MOFText`                TEXT         DEFAULT NULL,
  `Gath_AreaDetail`                   TEXT         DEFAULT NULL,
  `Gath_Code`                         VARCHAR(128) DEFAULT NULL,
  `Gath_Country_Name`                 VARCHAR(128) DEFAULT NULL,
  `Gath_Country_Name_Language`        VARCHAR(128) DEFAULT NULL,
  `Gath_Country_NameDerived`          VARCHAR(128) DEFAULT NULL,
  `Gath_Country_NameDerived_Language` VARCHAR(128) DEFAULT NULL,
  `Gath_Country_ISO`                  VARCHAR(4)   DEFAULT NULL,
  `Gath_DateTime_Text`                VARCHAR(128) DEFAULT NULL,
  `Gath_DateTime_Begin`               DATETIME     DEFAULT NULL,
  `Gath_DateTime_End`                 DATETIME     DEFAULT NULL,
  `Gath_DateTime_TimeZone`            VARCHAR(128) DEFAULT NULL,
  `Gath_Depth_Accuracy`               VARCHAR(128) DEFAULT NULL,
  `Gath_Depth_IsQuantitative`         VARCHAR(5)   DEFAULT NULL,
  `Gath_Depth_LowerValue`             VARCHAR(128) DEFAULT NULL,
  `Gath_Depth_DateTime`               VARCHAR(128) DEFAULT NULL,
  `Gath_Depth_Method`                 VARCHAR(255) DEFAULT NULL,
  `Gath_Depth_Parameter`              VARCHAR(255) DEFAULT NULL,
  `Gath_Depth_UnitOfMeasurement`      VARCHAR(255) DEFAULT NULL,
  `Gath_Depth_UpperValue`             VARCHAR(128) DEFAULT NULL,
  `Gath_Depth_MOFText`                TEXT         DEFAULT NULL,
  `Gath_GML`                          TEXT         DEFAULT NULL,
  `Gath_LocalityText`                 TEXT         DEFAULT NULL,
  `Gath_Method`                       TEXT         DEFAULT NULL,
  `Gath_Notes`                        TEXT         DEFAULT NULL,

  PRIMARY KEY (`_unitguid`),

  KEY `ix_biocase_gathering_01` (`_datasetguid`,`_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;


GO

DROP TABLE IF EXISTS `t_biocase_gathering_sitecoordinates`;

GO

CREATE TABLE  IF NOT EXISTS `t_biocase_gathering_sitecoordinates` (
  `_datasetguid`                    VARCHAR(36)    NOT NULL,
  `_unitguid`                       VARCHAR(36)    NOT NULL,
  `_sitecoordinatesguid`            VARCHAR(36)    NOT NULL,
  `begin`                           VARCHAR(64)    DEFAULT NULL,
  `end`                             VARCHAR(64)    DEFAULT NULL,
  `original`                        VARCHAR(64)    DEFAULT NULL,
  `CoordinateMethod`                VARCHAR(50)    DEFAULT NULL,
  `GridCellCode`                    VARCHAR(64)    DEFAULT NULL,
  `GridCellSystem`                  VARCHAR(64)    DEFAULT NULL,
  `GridQualifier`                   VARCHAR(64)    DEFAULT NULL,
  `AccuracyStatement`               VARCHAR(64)    DEFAULT NULL,
  `CoordinateErrorDistanceInMeters` DOUBLE         DEFAULT NULL,
  `CoordinateErrorMethod`           VARCHAR(128)   DEFAULT NULL,
  `CoordinateText`                  VARCHAR(128)   DEFAULT NULL,
  `LatitudeDecimal`                 DECIMAL(12,10) DEFAULT NULL,
  `LongitudeDecimal`                DECIMAL(13,10) DEFAULT NULL,
  `SpacialDatum`                    VARCHAR(64)    DEFAULT NULL,
  `UTMDatum`                        VARCHAR(255)   DEFAULT NULL,
  `UTMEasting`                      DECIMAL(19,2)  DEFAULT NULL,
  `UTMNS`                           VARCHAR(64)    DEFAULT NULL,
  `UTMNorthing`                     DECIMAL(19,2)  DEFAULT NULL,
  `UTMSubzone`                      VARCHAR(1)     DEFAULT NULL,
  `UTMText`                         VARCHAR(64)    DEFAULT NULL,
  `UTMZone`                         SMALLINT(6)    DEFAULT NULL,
  `UTMZoneFull`                     VARCHAR(64)    DEFAULT NULL,

  CONSTRAINT `pk_biocase_gathering_sitecoordinates_01` PRIMARY KEY (`_datasetguid`,`_unitguid`,`_sitecoordinatesguid`),
  CONSTRAINT `uq_biocase_gathering_sitecoordinates_01`  UNIQUE (`_sitecoordinatesguid`),

  KEY `ix_biocase_gathering_sitecoordinates_01` (`_datasetguid`, `_unitguid`),
  KEY `ix_biocase_gathering_sitecoordinates_02` (`_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_biocase_gathering_agent`;

GO

CREATE TABLE  IF NOT EXISTS `t_biocase_gathering_agent` (
  `_datasetguid`               VARCHAR(36)  NOT NULL,
  `_unitguid`                  VARCHAR(36)  NOT NULL,
  `_gatheringagentguid`        VARCHAR(36)  NOT NULL,
  `AgentText`                  Text         DEFAULT NULL,
  `OrgNameRepresentText`       Text         DEFAULT NULL,
  `OrgNameRepresent_Language`  VARCHAR(64)  DEFAULT NULL,
  `OrgNameRepresentAbbr`       VARCHAR(64)  DEFAULT NULL,
  `OrgUnit`                    VARCHAR(128) DEFAULT NULL,
  `OrgUnit_Language`           VARCHAR(64)  DEFAULT NULL,
  `PersonFullName`             VARCHAR(255) DEFAULT NULL,
  `PersonSortingName`          VARCHAR(128) DEFAULT NULL,
  `PersonInheritedName`        VARCHAR(128) DEFAULT NULL,
  `PersonPrefix`               VARCHAR(50)  DEFAULT NULL,
  `PersonSuffix`               VARCHAR(50)  DEFAULT NULL,
  `PersonGivenNames`           VARCHAR(128) DEFAULT NULL,
  `PersonPreferredName`        VARCHAR(128) DEFAULT NULL,
  `PrimaryCollector`           VARCHAR(5)   DEFAULT NULL,
  `Sequence`                   INT          DEFAULT NULL,

  CONSTRAINT `pk_biocase_gathering_agent_01` PRIMARY KEY (`_datasetguid`,`_unitguid`,`_gatheringagentguid`),
  CONSTRAINT `uq_biocase_gathering_agent_01` UNIQUE (`_gatheringagentguid`),

  KEY `ix_biocase_gathering_agent_01` (`_datasetguid`, `_unitguid`),
  KEY `ix_biocase_gathering_agent_02` (`_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_biocase_preparation`;

GO

CREATE TABLE  IF NOT EXISTS `t_biocase_preparation` (
  `_datasetguid`                  VARCHAR(36)  NOT NULL,
  `_unitguid`                     VARCHAR(36)  NOT NULL,
  `_preparationguid`              VARCHAR(36)  NOT NULL,
  `OrgNameRepresentText`          TEXT         DEFAULT NULL,
  `OrgNameRepresent_Language`     VARCHAR(64)  DEFAULT NULL,
  `OrgNameRepresentAbbr`          VARCHAR(64)  DEFAULT NULL,
  `OrgUnit`                       VARCHAR(128) DEFAULT NULL,
  `OrgUnit_Language`              VARCHAR(64)  DEFAULT NULL,
  `PersonFullName`                VARCHAR(255) DEFAULT NULL,
  `PersonSortingName`             VARCHAR(128) DEFAULT NULL,
  `PersonInheritedName`           VARCHAR(128) DEFAULT NULL,
  `PersonPrefix`                  VARCHAR(50)  DEFAULT NULL,
  `PersonSuffix`                  VARCHAR(50)  DEFAULT NULL,
  `PersonGivenNames`              VARCHAR(128) DEFAULT NULL,
  `PersonPreferredName`           VARCHAR(128) DEFAULT NULL,
  `PreparationMaterials`          TEXT         DEFAULT NULL,
  `PreparationMaterials_Language` VARCHAR(64)  DEFAULT NULL,
  `PreparationProcess`            TEXT         DEFAULT NULL,
  `PreparationProcess_Language`   VARCHAR(64)  DEFAULT NULL,
  `PreparationType`               TEXT         DEFAULT NULL,
  `PreparationType_Language`      VARCHAR(64)  DEFAULT NULL,

  CONSTRAINT `pk_biocase_preparation_01` PRIMARY KEY (`_datasetguid`,`_unitguid`,`_preparationguid`),
  CONSTRAINT `uq_biocase_preparation_01` UNIQUE (`_preparationguid`),

  KEY `ix_biocase_preparation_01` (`_datasetguid`, `_unitguid`),
  KEY `ix_biocase_preparation_02` (`_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO;

DELIMITER ;
