DELIMITER GO 

CREATE DATABASE IF NOT EXISTS `specify_biocasepreparer2`;

GO

USE `specify_biocasepreparer2`;

GO

-- DROP TABLE IF EXISTS `t_datasource`;

-- GO

-- Tabelle für Job-Definition
-- Verwaltet alle zu synchronisierenden Collections 
-- und enthält Angaben wie Datenbankname und den Collection-ShortCut.

-- Günther Korb 12.09.2013
-- Ergänzung Spalte metadataid

CREATE TABLE IF NOT EXISTS `t_datasource`
(
  `datasourceid`   INT          NOT NULL AUTO_INCREMENT,
  `alias`          VARCHAR(128) NOT NULL,
  `database`       VARCHAR(128) NOT NULL,
  `collectioncode` VARCHAR(128) NOT NULL,
  `description`    VARCHAR(255) NULL,
  `enabled`        BIT          NOT NULL DEFAULT 1,
  `metadataid`     VARCHAR(128) NOT NULL,

  CONSTRAINT `pk_datasource_01` PRIMARY KEY (`datasourceid`),
  CONSTRAINT `uq_datasource_01` UNIQUE (`alias`),
  CONSTRAINT `uq_datasource_02` UNIQUE (`database`, `collectioncode`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

GO

INSERT 
  INTO `t_datasource` (`alias`, `database`, `collectioncode`, `metadataid`)
       SELECT T1.* 
         FROM (SELECT 'Ehrenberg Samples' AS `alias`, 'specify' AS `database`, 'MB_ES' AS `collectioncode`, 'EB' AS `metadataid`
               UNION
               SELECT 'Ehrenberg Drawings' AS `alias`, 'specify' AS `database`, 'MB_ED' AS `collectioncode`, 'EB' AS `metadataid`
               UNION
               SELECT 'Aves', 'specify_publication', 'ZMB_Aves', 'Aves') AS T1 
              LEFT OUTER JOIN  `t_datasource` T2 ON (T1.`database`       = T2.`database`)
                                                AND (T1.`collectioncode` = T2.`collectioncode`)
        WHERE (T2.`datasourceid` IS NULL);

GO

 DROP TABLE IF EXISTS `t_mapping_collectionobject`;

GO

CREATE TABLE IF NOT EXISTS `t_mapping_collectionobject`
(
  `CollectionCode` VARCHAR(128)  NOT NULL,
  `Attribute`      VARCHAR(128)  NOT NULL,
  `AbcdConcept`    VARCHAR(1024) NOT NULL,
  `DestTable`      VARCHAR(128)  NOT NULL,
  `DestField`      VARCHAR(128)  NOT NULL,
  `Prefix`         VARCHAR(255)  NULL,         -- für 1:1
  `MarkType`       VARCHAR(128)  NULL,         -- für 1:n

  CONSTRAINT `pk_mapping_collectionobject_01` PRIMARY KEY (`collectioncode`, `attribute`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

INSERT 
  INTO `t_mapping_collectionobject` (`CollectionCode`, `Attribute`, `AbcdConcept`, `DestTable`, `DestField`, `Prefix`, `MarkType`)
       SELECT T1.* 
         FROM (SELECT 'MB_ED' AS `CollectionCode`, 
                      'text1' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/SpecimenUnit/Marks/Mark/MarkText' AS `AbcdConcept`, 
                      't_biocase_unit_specimenunit_mark' AS `DestTable`, 
                      'marktext' AS `DestField`, 
                      NULL AS `Prefix`, 
                      'label' AS  `MarkType`
              ) AS T1 
              LEFT OUTER JOIN `t_mapping_collectionobject` T2 ON (T1.`collectioncode` = T2.`collectioncode`)
                                                             AND (T1.`attribute`      = T2.`attribute`)
        WHERE (T2.`collectioncode` IS NULL);

GO

 DROP TABLE IF EXISTS `t_mapping_collectionobjectattribute`;

GO

-- Günther Korb 20.09.2013
-- Ergänzung um Attribut 'Parameter' für measurementsOrFacts

CREATE TABLE IF NOT EXISTS `t_mapping_collectionobjectattribute`
(
  `CollectionCode` VARCHAR(128)  NOT NULL,
  `Attribute`      VARCHAR(128)  NOT NULL,
  `AbcdConcept`    VARCHAR(1024) NOT NULL,
  `DestTable`      VARCHAR(128)  NOT NULL,
  `DestField`      VARCHAR(128)  NOT NULL,
  `Prefix`         VARCHAR(255)  NULL,         -- für 1:1
  `MarkType`       VARCHAR(128)  NULL,         -- für 1:n
  `Parameter`      VARCHAR(255)  NULL,

  CONSTRAINT `pk_mapping_collectionobjectattribute_01` PRIMARY KEY (`collectioncode`, `attribute`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

INSERT 
  INTO `t_mapping_collectionobjectattribute` (`CollectionCode`, `Attribute`, `AbcdConcept`, `DestTable`, `DestField`)
       SELECT T1.* 
         FROM (SELECT 'ZMB_Aves' AS `collectioncode`, 
                      'text8' AS `attribute`, 
                      '/DataSets/DataSet/Units/Unit/Sex' AS `abcdconcept`,
                      't_biocase_unit' AS `desttable`,
                      'sex' AS `destfield`
               UNION
               SELECT 'ZMB_Aves', 'text7', '/DataSets/DataSet/Units/Unit/Age', 't_biocase_unit', 'age'
              ) AS T1 
              LEFT OUTER JOIN `t_mapping_collectionobjectattribute` T2 ON (T1.`collectioncode` = T2.`collectioncode`)
                                                                      AND (T1.`attribute`      = T2.`attribute`)
        WHERE (T2.`collectioncode` IS NULL);

GO

INSERT 
  INTO `t_mapping_collectionobjectattribute` (`CollectionCode`, `Attribute`, `AbcdConcept`, `DestTable`, `DestField`, `Prefix`, `MarkType`)
       SELECT T1.* 
         FROM (SELECT 'MB_ED' AS `CollectionCode`, 
                      'text1' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/SpecimenUnit/Marks/Mark/MarkText' AS `AbcdConcept`, 
                      't_biocase_unit_specimenunit_mark' AS `DestTable`, 
                      'marktext' AS `DestField`, 
                      'name folder: ' AS `Prefix`, 
                      'inscription' AS  `MarkType`
               UNION
               SELECT 'MB_ED', 'text2', '/DataSets/DataSet/Units/Unit/SpecimenUnit/Marks/Mark/MarkText', 't_biocase_unit_specimenunit_mark', 'marktext', 'taxon folder: ', 'inscription'
               UNION
               SELECT 'MB_ED', 'text3', '/DataSets/DataSet/Units/Unit/SpecimenUnit/Marks/Mark/MarkText', 't_biocase_unit_specimenunit_mark', 'marktext', 'place folder: ', 'inscription'
              ) AS T1 
              LEFT OUTER JOIN `t_mapping_collectionobjectattribute` T2 ON (T1.`collectioncode` = T2.`collectioncode`)
                                                                      AND (T1.`attribute`      = T2.`attribute`)
        WHERE (T2.`collectioncode` IS NULL);

GO

-- Günther Korb 20.09.2013
-- Erweiterung des Mappings des collectionobjectattributes 
-- Mapping auf MeasurementsOrFacts
--    Aves (recent)

INSERT 
  INTO `t_mapping_collectionobjectattribute` (`CollectionCode`, `Attribute`, `AbcdConcept`, 
				`DestTable`, `DestField`, `Parameter`)
       SELECT T1.* 
         FROM (SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text4' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Body' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text5' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Stomach' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text6' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Gonads' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text7' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Age' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text8' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Sex' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text9' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Molt' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text10' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Repro condition' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text11' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Color of feet' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text12' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Color of eyering' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text13' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Color of eye' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'text14' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Color of bill' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'Number1' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Weight (g)' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'Number2' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Wing length (mm)' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'Number3' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Tail length (mm)' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'Number4' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Bill length (mm)' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'Number5' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Tarsus length (mm)' AS `Parameter`
               UNION
               SELECT 'ZMB_Aves' AS `CollectionCode`, 
                      'Number6' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Total length (mm)' AS `Parameter`
                UNION
               SELECT 'MB_ED' AS `CollectionCode`, 
                      'Text4' AS `Attribute`, 
                      '/DataSets/DataSet/Units/Unit/MeasurementsOrFacts/MeasurementOrFact/MeasurementOrFactAtomised/LowerValue' AS `AbcdConcept`, 
                      't_biocase_measurementsorfacts' AS `DestTable`, 
                      'LowerValue' AS `DestField`, 
                      'Type' AS `Parameter`
             ) AS T1 
              LEFT OUTER JOIN `t_mapping_collectionobjectattribute` T2 ON (T1.`collectioncode` = T2.`collectioncode`)
                                                                      AND (T1.`attribute`      = T2.`attribute`)
        WHERE (T2.`collectioncode` IS NULL);

GO

DROP TABLE IF EXISTS `t_steps`;

GO

CREATE TABLE IF NOT EXISTS `t_steps`
(
  `id`        INT          NOT NULL AUTO_INCREMENT,
  `Object`    VARCHAR(128),
  `StepID`    DOUBLE,
  `Timestamp` DATETIME,

  PRIMARY KEY (`id`)
) ENGINE=MEMORY;

GO

DROP TABLE IF EXISTS `t_tmp_biocase_unit`;

GO

CREATE TABLE IF NOT EXISTS `t_tmp_biocase_unit`
(
  `_datasetguid`          VARCHAR(36)   NOT NULL,
  `_unitguid`             VARCHAR(36)   NOT NULL,
  `SourceInstitutionID`   VARCHAR(128)  NOT NULL,
  `SourceID`              VARCHAR(128)  NOT NULL,
  `UnitID`                VARCHAR(128)  NOT NULL,
  `UnitIDNumeric`         INT           NULL,
  `LastEditor`            VARCHAR(128)  NULL,
  `DateLastEdited`        DATETIME      NULL,
  `RecordBasis`           VARCHAR(128)  NULL,
  `CollectorsFieldNumber` VARCHAR(128)  NULL,
  `Sex`                   VARCHAR(128)  NULL,
  `Age`                   VARCHAR(128)  NULL,
  `RecordURI`             VARCHAR(1024) NULL,
  `Notes`                 TEXT          NULL,

  CONSTRAINT `pk_tmp_biocase_unit_01` PRIMARY KEY (`_unitguid`),
  CONSTRAINT `uq_tmp_biocase_unit_01` UNIQUE (`SourceInstitutionID`, `SourceID`, `UnitID`),

  KEY `ix_tmp_biocase_unit_01` (`_datasetguid`, `_unitguid`),
  KEY `ix_tmp_biocase_unit_02` (`UnitID`, `_unitguid`),
  KEY `ix_tmp_biocase_unit_03` (`DateLastEdited`, `_unitguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_tmp_biocase_identification`;

GO

CREATE TABLE IF NOT EXISTS `t_tmp_biocase_identification`
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

  CONSTRAINT `pk_tmp_biocase_unit_01` PRIMARY KEY (`_identificationguid`),

  KEY `ix_tmp_biocase_identification_01` (`_unitguid`,`_identificationguid`),
  KEY `ix_tmp_biocase_identification_02` (`ScientificName`,`_unitguid`),
  KEY `ix_tmp_biocase_identification_03` (`FullScientificNameString`,`_unitguid`),
  KEY `ix_tmp_biocase_identification_04` (`GenusOrMonomial`,`_unitguid`),
  KEY `ix_tmp_biocase_identification_05` (`Subgenus`,`_unitguid`),
  KEY `ix_tmp_biocase_identification_06` (`SpeciesEpithet`,`_unitguid`),
  KEY `ix_tmp_biocase_identification_07` (`SubspeciesEpithet`,`_unitguid`)
)

GO

DROP TABLE IF EXISTS `t_tmp_biocase_identification_highertaxon`;

GO

CREATE TABLE IF NOT EXISTS `t_tmp_biocase_identification_highertaxon`
(
  `_identificationguid` VARCHAR(36)   NOT NULL,
  `HigherTaxonName`     VARCHAR(128)  NOT NULL,
  `HigherTaxonRank`     VARCHAR(16)   NOT NULL,
  
  CONSTRAINT `pk_tmp_biocase_identification_highertaxon_01` PRIMARY KEY (`_identificationguid`, `HigherTaxonRank`),

  KEY `ix_tmp_biocase_identification_highertaxon_01` (`HigherTaxonName`, `_identificationguid`),
  KEY `ix_tmp_biocase_identification_highertaxon_02` (`HigherTaxonRank`, `_identificationguid`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_tmp_biocase_specimenunit_mark`;

GO

CREATE TABLE IF NOT EXISTS `t_tmp_biocase_specimenunit_mark`
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

  CONSTRAINT `pk_tmp_biocase_specimenunit_mark_01` PRIMARY KEY (`_datasetguid`, `_unitguid`, `_markguid`),
  CONSTRAINT `uq_tmp_biocase_specimenunit_mark_01` UNIQUE (`_markguid`)
)

GO

DROP TABLE IF EXISTS `t_tmp_guid`;

GO

CREATE TABLE IF NOT EXISTS `t_tmp_guid`
(
  `guid` VARCHAR(36) PRIMARY KEY
) ENGINE=MEMORY;

GO

DROP TABLE IF EXISTS `t_tmp_lastedited`;

GO

CREATE TABLE IF NOT EXISTS `t_tmp_lastedited`
(
  `CollectionObjectID` INT NOT NULL,
  `LastEditor`         INT,
  `DateLastEdited`     DATETIME,

  CONSTRAINT `pk_lastedited` PRIMARY KEY (`CollectionObjectID`),
  KEY `ix_lastedit_01` (`DateLastEdited`, `CollectionObjectID`)

) ENGINE=MEMORY DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_tmp_colltaxa`;

GO

CREATE TABLE IF NOT EXISTS `t_tmp_colltaxa`
(
  `TaxonTreeDefID`  INT,
  `TaxonID`         INT,
  `ParentID`        INT,
  `RankID`          INT,
  `GenusOrMonomial` NVARCHAR(64),
  `GenusID`         INT,
  `Subgenus`        NVARCHAR(64),
  `SubgenusID`      INT,
  `Species`         NVARCHAR(64),
  `SpeciesID`       INT,
  `Subspecies`      NVARCHAR(64),
  `SubpeciesID`     INT,
  `Author`          NVARCHAR(128),
  `Subtribe`        NVARCHAR(64),
  `SubtribeID`      INT,
  `Tribe`           NVARCHAR(64),
  `TribeID`         INT,
  `Subfamily`       NVARCHAR(64),
  `SubfamilyID`     INT,
  `Family`          NVARCHAR(64),
  `FamilyID`        INT,
  `Infraorder`      NVARCHAR(64),
  `InfraorderID`    INT,
  `Suborder`        NVARCHAR(64),
  `SuborderID`      INT,
  `Order`           NVARCHAR(64),
  `OrderID`         INT,
  `Superorder`      NVARCHAR(64),
  `SuperorderID`    INT,
  `Infraclass`      NVARCHAR(64),
  `InfraclassID`    INT,
  `Subclass`        NVARCHAR(64),
  `SubclassID`      INT,
  `Class`           NVARCHAR(64),
  `ClassID`         INT,
  `Superclass`      NVARCHAR(64),
  `SuperclassID`    INT,
  `Subphylum`       NVARCHAR(64),
  `SubphylumID`     INT,
  `Phylum`          NVARCHAR(64),
  `PhylumID`        INT,
  `Kingdom`         NVARCHAR(64),
  `KingdomID`       INT,
  `Life`            NVARCHAR(64),
  `LifeID`          INT,

  CONSTRAINT `pk_colltaxa_01` PRIMARY KEY (`TaxonTreeDefID`,`TaxonID`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_imp_biocase_identification_highertaxon`;

GO

CREATE TABLE IF NOT EXISTS `t_imp_biocase_identification_highertaxon`
(
  `_identificationguid` VARCHAR(36)  NOT NULL, 
  `HigherTaxonName`     VARCHAR(255) NOT NULL,
  `HigherTaxonRank`     VARCHAR(32)  NOT NULL,

  CONSTRAINT `pk_imp_biocase_identification_highertaxon` PRIMARY KEY (`_identificationguid`, `HigherTaxonRank`)

) ENGINE=INNODB DEFAULT CHARSET=utf8;

GO

DROP TABLE IF EXISTS `t_tmp_geography`;

GO

CREATE TABLE IF NOT EXISTS `t_tmp_geography`
(
  `GeographyTreeDefID` INT,
  `GeographyID`        INT,
  `ParentID`           INT,
  `RankID`             INT,
  `County`             NVARCHAR(64),
  `CountyID`           INT,
  `State`              NVARCHAR(64),
  `StateID`            INT,
  `Country`            NVARCHAR(64),
  `CountryID`          INT,
  `Continent`          NVARCHAR(64),
  `ContinentID`        INT,

  CONSTRAINT `pk_geography_01` PRIMARY KEY (`GeographyTreeDefID`,`GeographyID`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

-- Günther Korb 09.09.2013
-- Multimediaobjekte

DROP TABLE IF EXISTS `t_tmp_biocase_multimediaobject`;

GO

CREATE TABLE  IF NOT EXISTS `t_tmp_biocase_multimediaobject` (
  `_datasetguid`		varchar(36) NOT NULL,
  `_unitguid`			varchar(36) NOT NULL,
  `_mmoguid`			varchar(36) NOT NULL,
  `CumulusID`			int(11) NOT NULL,
  `UnitID`				varchar(45) NOT NULL,
  `CumulusAssetName`	varchar(255) DEFAULT NULL,
  `Format`				varchar(45) DEFAULT NULL,
  `FileURI`				varchar(255) DEFAULT NULL,
  `ProductURI`			varchar(255) DEFAULT NULL,
  `IPRText`				varchar(255) DEFAULT NULL,
  `IPRDetails`			varchar(1024) DEFAULT NULL,
  `IPRURI`				varchar(255) DEFAULT NULL,
  `LicenseText`			varchar(255) DEFAULT NULL,
  `LicenseDetails`		varchar(1024) DEFAULT NULL,
  `LicenseURI`			varchar(255) DEFAULT NULL,

  CONSTRAINT `pk_tmp_biocase_multimediaobject_01` PRIMARY KEY (`CumulusID`,`_unitguid`),
  CONSTRAINT `uq_tmp_biocase_multimediaobject_01` UNIQUE (`_mmoguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GO

-- Günther Korb 10.09.2013
-- Tabelle abcd-Metadaten

DROP TABLE IF EXISTS `t_metadata_template`;

GO

CREATE TABLE  IF NOT EXISTS  `t_metadata_template` (
  `MetadataTemplateID` 			varchar(36) NOT NULL,
  `DatasetGUID` 				varchar(255) DEFAULT NULL,
  `TechnicalContactName` 		varchar(255) DEFAULT NULL,
  `TechnicalContactEmail` 		varchar(255) DEFAULT NULL,
  `TechnicalContactPhone` 		varchar(255) DEFAULT NULL,
  `TechnicalContactAddress` 	varchar(255) DEFAULT NULL,
  `ContentContactName` 			varchar(255) DEFAULT NULL,
  `ContentContactEmail` 		varchar(255) DEFAULT NULL,
  `ContentContactPhone` 		varchar(255) DEFAULT NULL,
  `ContentContactAddress` 		varchar(255) DEFAULT NULL,
  `OtherProviderUDDI` 			varchar(255) DEFAULT NULL,
  `DatasetTitle` 				varchar(255) DEFAULT NULL,
  `DatasetDetails` 				varchar(1024) DEFAULT NULL,
  `DatasetCoverage` 			varchar(255) DEFAULT NULL,
  `DatasetURI` 					varchar(255) DEFAULT NULL,
  `DatasetIconURI` 				varchar(255) DEFAULT NULL,
  `DatasetVersionMajor` 		varchar(255) DEFAULT NULL,
  `DatasetVersionMinor` 		varchar(255) DEFAULT NULL,
  `DatasetCreators` 			varchar(255) DEFAULT NULL,
  `DatasetContributors` 		varchar(255) DEFAULT NULL,
  `DateCreated` 				varchar(255) DEFAULT NULL,
  `DateModified` 				varchar(255) DEFAULT NULL,
  `OwnerOrganizationName` 		varchar(255) DEFAULT NULL,
  `OwnerOrganizationAbbrev` 	varchar(255) DEFAULT NULL,
  `OwnerContactPerson` 			varchar(255) DEFAULT NULL,
  `OwnerContactRole` 			varchar(255) DEFAULT NULL,
  `OwnerAddress` 				varchar(255) DEFAULT NULL,
  `OwnerTelephone` 				varchar(255) DEFAULT NULL,
  `OwnerEmail` 					varchar(255) DEFAULT NULL,
  `OwnerURI` 					varchar(255) DEFAULT NULL,
  `OwnerLogoURI` 				varchar(255) DEFAULT NULL,
  `IPRText` 					varchar(255) DEFAULT NULL,
  `IPRDetails` 					varchar(1024) DEFAULT NULL,
  `IPRURI` 						varchar(255) DEFAULT NULL,
  `CopyrightText` 				varchar(255) DEFAULT NULL,
  `CopyrightDetails` 			varchar(1024) DEFAULT NULL,
  `CopyrightURI` 				varchar(255) DEFAULT NULL,
  `TermsOfUseText` 				varchar(255) DEFAULT NULL,
  `TermsOfUseDetails` 			varchar(1024) DEFAULT NULL,
  `TermsOfUseURI`				varchar(255) DEFAULT NULL,
  `DisclaimersText` 			varchar(255) DEFAULT NULL,
  `DisclaimersDetails` 			varchar(1024) DEFAULT NULL,
  `DisclaimersURI` 				varchar(255) DEFAULT NULL,
  `LicenseText` 				varchar(255) DEFAULT NULL,
  `LicenseDetails` 				varchar(1024) DEFAULT NULL,
  `LicenseURI` 					varchar(255) DEFAULT NULL,
  `AcknowledgementsText` 		varchar(255) DEFAULT NULL,
  `AcknowledgementsDetails` 	varchar(1024) DEFAULT NULL,
  `AcknowledgementsURI` 		varchar(255) DEFAULT NULL,
  `CitationsText` 				varchar(255) DEFAULT NULL,
  `CitationsDetails` 			varchar(1024) DEFAULT NULL,
  `CitationsURI` 				varchar(255) DEFAULT NULL,
  `SourceInstitutionID` 		varchar(255) DEFAULT NULL,
  `SourceID` 					varchar(255) DEFAULT NULL,
  `RecordBasis` 				varchar(255) DEFAULT NULL,
  `KindOfUnit` 					varchar(255) DEFAULT NULL,

  CONSTRAINT `pk_metadata_template_01` PRIMARY KEY (`MetadataTemplateID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Metadata-Template for Biocase-Mapping'

GO

-- Günther Korb 10.09.2013
-- Einträge in Tabelle abcd-Metadaten

INSERT 
  INTO `t_metadata_template`
       SELECT T1.* 
         FROM (SELECT 'EB' 												AS `MetadataTemplateID`, 
					  NULL 												AS `DatasetGUID`, 
					  'GeoCASE-Team' 									AS `TechnicalContactName`,
					  'geocase@mfn-berlin.de' 							AS `TechnicalContactEmail`, 
					  '+49 30 2093 8672' 								AS `TechnicalContactPhone`,
					  'Museum fuer Naturkunde Invaliden Str. 43 10115 Berlin Deutschland' AS TechnicalContactAddress, 
					  'David Lazarus' 									AS ContentContactName, 
					  'David.Lazarus@mfn-berlin.de' 					AS ContentContactEmail,
					  '+49 30 2093 8579' 								AS ContentContactPhone, 
					  'Museum fuer Naturkunde Invaliden Str. 43 10115 Berlin Deutschland' AS ContentContactAddress, 
					  NULL 												AS OtherProviderUDDI,
					  NULL 												AS `DatasetTitle`, 
					  NULL 												AS `DatasetDetails`,
					  NULL 												AS `DatasetCoverage`,
					  NULL 												AS `DatasetURI`,
					  NULL 												AS `DatasetIconURI`,
					  NULL 												AS `DatasetVersionMajor`,
					  NULL 												AS `DatasetVersionMinor`,
					  NULL 												AS `DatasetCreators`,
					  NULL 												AS `DatasetContributors`,
					  NULL 												AS `DateCreated`,
					  NULL 												AS `DateModified`,
					  'Museum fuer Naturkunde' 							AS `OwnerOrganizationName`,
					  'MfN' 											AS `OwnerOrganizationAbbrev`,
					  'David Lazarus' 									AS `OwnerContactPerson`,
					  NULL 												AS `OwnerContactRole`,
					  'Museum fuer Naturkunde Invaliden Str. 43 10115 Berlin Deutschland' AS `OwnerAddress`,
					  '+49 30 2093 8579' 								AS `OwnerTelephone`,
					  'David.Lazarus@mfn-berlin.de' 					AS `OwnerEmail`,
					  NULL 												AS `OwnerURI`,
					  NULL 												AS `OwnerLogoURI`,
					  'Creative Commons (CC-by)' 						AS `IPRText`,
					  'Creative Commons (CC-by)' 						AS `IPRDetails`,
					  'http://creativecommons.org/licenses/by/3.0/' 	AS `IPRURI`,
					  NULL 												AS `CopyrightText`,
					  NULL 												AS `CopyrightDetails`,
					  NULL 												AS `CopyrightURI`,
					  NULL 												AS `TermsOfUseText`,
					  NULL 												AS `TermsOfUseDetails`,
					  NULL 												AS `TermsOfUseURI`,
					  NULL 												AS `DisclaimersText`,
					  NULL 												AS `DisclaimersDetails`,
					  NULL 												AS `DisclaimersURI`,
					  'Creative Commons (CC-by)' 						AS `LicenseText`,
					  'Creative Commons (CC-by)' 						AS `LicenseDetails`,
					  'http://creativecommons.org/licenses/by/3.0/' 	AS `LicenseURI`,
					  NULL 												AS `AcknowledgementsText`,
					  NULL 												AS `AcknowledgementsDetails`,
					  NULL 												AS `AcknowledgementsURI`,
					  NULL 												AS `CitationsText`,
					  NULL 												AS `CitationsDetails`,
					  NULL 												AS `CitationsURI`,
					  NULL 												AS `SourceInstitutionID`,
					  NULL 												AS `SourceID`,
					  NULL 												AS `RecordBasis`,
					  NULL 												AS `KindOfUnit`
                UNION 
               SELECT 'Aves' 											AS `MetadataTemplateID`, 
					  NULL 												AS `DatasetGUID`, 
					  'GeoCASE-Team' 									AS `TechnicalContactName`,
					  'geocase@mfn-berlin.de' 							AS `TechnicalContactEmail`, 
					  '+49 30 2093 8672' 								AS `TechnicalContactPhone`,
					  'Museum fuer Naturkunde Invaliden Str. 43 10115 Berlin Deutschland' AS TechnicalContactAddress, 
					  'Sylke Frahnert' 									AS ContentContactName, 
					  'sylke.frahnert@mfn-berlin.de' 					AS ContentContactEmail,
					  '+49 30 2093 8579' 								AS ContentContactPhone, 
					  'Museum fuer Naturkunde Invaliden Str. 43 10115 Berlin Deutschland' AS ContentContactAddress, 
					  NULL 												AS OtherProviderUDDI,
					  NULL 									AS `DatasetTitle`, 
					  NULL 												AS `DatasetDetails`,
					  NULL 												AS `DatasetCoverage`,
					  NULL 												AS `DatasetURI`,
					  NULL 												AS `DatasetIconURI`,
					  NULL 												AS `DatasetVersionMajor`,
					  NULL 												AS `DatasetVersionMinor`,
					  NULL 												AS `DatasetCreators`,
					  NULL 												AS `DatasetContributors`,
					  NULL 												AS `DateCreated`,
					  NULL 												AS `DateModified`,
					  'Museum fuer Naturkunde' 							AS `OwnerOrganizationName`,
					  'MfN' 											AS `OwnerOrganizationAbbrev`,
					  'Sylke Frahnert' 									AS `OwnerContactPerson`,
					  NULL 												AS `OwnerContactRole`,
					  'Museum fuer Naturkunde Invaliden Str. 43 10115 Berlin Deutschland' AS `OwnerAddress`,
					  '+49 30 2093 8579' 								AS `OwnerTelephone`,
					  'sylke.frahnert@mfn-berlin.de' 					AS `OwnerEmail`,
					  NULL 												AS `OwnerURI`,
					  NULL 												AS `OwnerLogoURI`,
					  'Creative Commons (CC-by)' 						AS `IPRText`,
					  'Creative Commons (CC-by)' 						AS `IPRDetails`,
					  'http://creativecommons.org/licenses/by/3.0/' 	AS `IPRURI`,
					  NULL 												AS `CopyrightText`,
					  NULL 												AS `CopyrightDetails`,
					  NULL 												AS `CopyrightURI`,
					  NULL 												AS `TermsOfUseText`,
					  NULL 												AS `TermsOfUseDetails`,
					  NULL 												AS `TermsOfUseURI`,
					  NULL 												AS `DisclaimersText`,
					  NULL 												AS `DisclaimersDetails`,
					  NULL 												AS `DisclaimersURI`,
					  'Creative Commons (CC-by)' 						AS `LicenseText`,
					  'Creative Commons (CC-by)' 						AS `LicenseDetails`,
					  'http://creativecommons.org/licenses/by/3.0/' 	AS `LicenseURI`,
					  NULL 												AS `AcknowledgementsText`,
					  NULL 												AS `AcknowledgementsDetails`,
					  NULL 												AS `AcknowledgementsURI`,
					  NULL 												AS `CitationsText`,
					  NULL 												AS `CitationsDetails`,
					  NULL 												AS `CitationsURI`,
					  NULL 												AS `SourceInstitutionID`,
					  NULL 												AS `SourceID`,
					  NULL 												AS `RecordBasis`,
					  NULL 												AS `KindOfUnit`
                UNION
               SELECT 'XXX' 											AS `MetadataTemplateID`, 
					  NULL 												AS `DatasetGUID`, 
					  'GeoCASE-Team' 									AS `TechnicalContactName`,
					  'geocase@mfn-berlin.de' 							AS `TechnicalContactEmail`, 
					  '+49 30 2093 8672' 								AS `TechnicalContactPhone`,
					  'Museum fuer Naturkunde Invaliden Str. 43 10115 Berlin Deutschland' AS TechnicalContactAddress, 
					  'N N'			 									AS ContentContactName, 
					  'n.n@mfn-berlin.de' 								AS ContentContactEmail,
					  '+49 30 2093 8579' 								AS ContentContactPhone, 
					  'Museum fuer Naturkunde Invaliden Str. 43 10115 Berlin Deutschland' AS ContentContactAddress, 
					  NULL 												AS OtherProviderUDDI,
					  'XXX' 											AS `DatasetTitle`, 
					  NULL 												AS `DatasetDetails`,
					  NULL 												AS `DatasetCoverage`,
					  NULL 												AS `DatasetURI`,
					  NULL 												AS `DatasetIconURI`,
					  NULL 												AS `DatasetVersionMajor`,
					  NULL 												AS `DatasetVersionMinor`,
					  NULL 												AS `DatasetCreators`,
					  NULL 												AS `DatasetContributors`,
					  NULL 												AS `DateCreated`,
					  NULL 												AS `DateModified`,
					  'Museum fuer Naturkunde' 							AS `OwnerOrganizationName`,
					  'MfN' 											AS `OwnerOrganizationAbbrev`,
					  'N N' 											AS `OwnerContactPerson`,
					  NULL 												AS `OwnerContactRole`,
					  'Museum fuer Naturkunde Invaliden Str. 43 10115 Berlin Deutschland' AS `OwnerAddress`,
					  '+49 30 2093 8579' 								AS `OwnerTelephone`,
					  'n.n@mfn-berlin.de' 								AS `OwnerEmail`,
					  NULL 												AS `OwnerURI`,
					  NULL 												AS `OwnerLogoURI`,
					  'Creative Commons (CC-by)' 						AS `IPRText`,
					  'Creative Commons (CC-by)' 						AS `IPRDetails`,
					  'http://creativecommons.org/licenses/by/3.0/' 	AS `IPRURI`,
					  NULL 												AS `CopyrightText`,
					  NULL 												AS `CopyrightDetails`,
					  NULL 												AS `CopyrightURI`,
					  NULL 												AS `TermsOfUseText`,
					  NULL 												AS `TermsOfUseDetails`,
					  NULL 												AS `TermsOfUseURI`,
					  NULL 												AS `DisclaimersText`,
					  NULL 												AS `DisclaimersDetails`,
					  NULL 												AS `DisclaimersURI`,
					  'Creative Commons (CC-by)' 						AS `LicenseText`,
					  'Creative Commons (CC-by)' 						AS `LicenseDetails`,
					  'http://creativecommons.org/licenses/by/3.0/' 	AS `LicenseURI`,
					  NULL 												AS `AcknowledgementsText`,
					  NULL 												AS `AcknowledgementsDetails`,
					  NULL 												AS `AcknowledgementsURI`,
					  NULL 												AS `CitationsText`,
					  NULL 												AS `CitationsDetails`,
					  NULL 												AS `CitationsURI`,
					  'MFN' 											AS `SourceInstitutionID`,
					  'XX' 												AS `SourceID`,
					  'Preserved Specimen' 								AS `RecordBasis`,
					  NULL 												AS `KindOfUnit`
				) AS T1
              LEFT OUTER JOIN  `t_metadata_template` T2 ON (T1.`MetadataTemplateID`       = T2.`MetadataTemplateID`)
        WHERE (T2.`MetadataTemplateID` IS NULL);

GO

DROP PROCEDURE IF EXISTS `p_prepareDataset`;

GO

-- Günther Korb 16.09.2013
-- Einlesen des Schlüssels für den Metadatatemplatedatensatz

CREATE PROCEDURE `p_prepareDataset`($datasourceid INT)
BEGIN
  SET @databasename =     (SELECT `database`
                             FROM `t_datasource`
                            WHERE (`datasourceid` = $datasourceid));

  SET @collectioncode =   (SELECT `collectioncode`
                             FROM `t_datasource`
                            WHERE (`datasourceid` = $datasourceid));

  SET @metadatatemplate = (SELECT `metadataid`
                             FROM `t_datasource`
                            WHERE (`datasourceid` = $datasourceid));

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 0, NOW());

  SET @sql = CONCAT('CREATE OR REPLACE VIEW `v_imp_dataset`
					 AS
                       SELECT `Guid`
                         FROM `', @databasename ,'`.`collection`
                        WHERE `Code` = \'', @collectioncode ,'\';');

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 1, NOW());

  SET @sql = REPLACE('
  CREATE OR REPLACE VIEW `v_imp_agent`
  AS
    SELECT `AgentID`,
           CONCAT(CONCAT(COALESCE(NULLIF(`FirstName`,\'\'),\' \'),\'\') 
                 ,CONCAT(COALESCE(NULLIF(`MiddleInitial`,\'\'),\' \'),\'\') 
                 ,`LastName`) AS `FullName`
      FROM `svar_sourcedb_`.`agent`;', 'svar_sourcedb_', @databasename);

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 2, NOW());

  SET @sql = REPLACE(CONCAT('
  CREATE OR REPLACE VIEW `v_imp_biocase_unit`
  AS
    SELECT T6.`Guid`                       AS `_datasetguid`,
           T1.`Guid`                       AS `_unitguid`,              
           T9.`Code`                       AS `SourceInstitutionID`,   
           T6.`Code`                       AS `SourceID`,              
           T1.`ReservedText`               AS `UnitID`,
           NULL                            AS `UnitIDNumeric`,         
           COALESCE(T5.`FullName`
                   ,T4.`FullName`)         AS `LastEditor`,            
           COALESCE(T1.`TimestampModified`
                   ,T1.`TimestampCreated`) AS `DateLastEdited`,        
           T1.`Description`                AS `RecordBasis`,
           T2.`StationFieldNumber`         AS `CollectorsFieldNumber`,
           NULL                            AS `Sex`,      
           NULL                            AS `Age`,
           NULL                            AS `RecordURI`,
           T1.remarks                      AS `Notes`                 
      FROM `svar_sourcedb_`.`institution`                               T9
           INNER JOIN `svar_sourcedb_`.`division`                       T8 ON (T9.`InstitutionID`               = T8.`InstitutionID`)
           INNER JOIN `svar_sourcedb_`.`discipline`                     T7 ON (T8.`DivisionID`                  = T7.`DivisionID`)
           INNER JOIN `svar_sourcedb_`.`collection`                     T6 ON (T7.`DisciplineID`                = T6.`DisciplineID`)
           INNER JOIN `svar_sourcedb_`.`collectionobject`               T1 ON (T6.`CollectionID`                = T1.`CollectionID`)
           LEFT OUTER JOIN `svar_sourcedb_`.`collectingevent`           T2 ON (T1.`CollectingEventID`           = T2.`CollectingEventID`)
           LEFT OUTER JOIN `svar_sourcedb_`.`collectionobjectattribute` T3 ON (T1.`CollectionObjectAttributeID` = T3.`CollectionObjectAttributeID`)
           LEFT OUTER JOIN `v_imp_agent`                                T4 ON (T1.`CreatedByAgentID`            = T4.`AgentID`)
           LEFT OUTER JOIN `v_imp_agent`                                T5 ON (T1.`ModifiedByAgentID`           = T5.`AgentID`)
     WHERE T6.`Code` = \'', @collectioncode, '\';'),
  'svar_sourcedb_', @databasename);

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 3, NOW());


  SET @sql = REPLACE(CONCAT('
  CREATE OR REPLACE VIEW `v_imp_biocase_identification`
  AS
    SELECT T1.`Guid` AS `_unitguid`,
           T2.`Guid` AS `_identificationguid`,
           COALESCE(T2.`TimestampModified`,T2.`TimestampCreated`) AS `_timestamp`,

           CONCAT(T3.`GenusOrMonomial`
                 ,COALESCE(CONCAT(\' \',NULLIF(T3.`Subgenus`,\'\')),\'\')
                 ,COALESCE(CONCAT(\' \',NULLIF(T3.`Species`,\'\')),\'\')
                 ,COALESCE(CONCAT(\' \',NULLIF(T3.`Subspecies`,\'\')),\'\'))
           AS `ScientificName`,
           CONCAT(`GenusOrMonomial`
                 ,COALESCE(CONCAT(\' \',NULLIF(T3.`Subgenus`,\'\')),\'\')
                 ,COALESCE(CONCAT(\' \',NULLIF(T3.`Species`,\'\')),\'\')
                 ,COALESCE(CONCAT(\' \',NULLIF(T3.`Subspecies`,\'\')),\'\')
                 ,COALESCE(CONCAT(\' \',NULLIF(T3.`Author`,\'\')),\'\'))
           AS `FullScientificNameString`,
           T3.`GenusOrMonomial`,
           T3.`Subgenus`,
           T3.`Species` AS `SpeciesEpithet`,
           T3.`Subspecies` AS `SubspeciesEpithet`,
          CASE
            WHEN (T3.`Author` NOT LIKE \'(%\')
            THEN T3.`Author`
            ELSE \'\'
          END AS `AuthorTeamOriginalAndYear`,
          CASE
            WHEN (T3.`Author` LIKE \'(%\')
            THEN T3.`Author`
            ELSE \'\'
          END AS `AuthorTeamParenthesisAndYear`,
          NULL AS `CombinationAuthorTeamAndYear`,
          NULL AS `Breed`,
          NULL AS `NamedIndividual`,
          NULL AS `IdentificationQualifier`,
          NULL AS `IdentificationQualifier_insertionpoint`,
          T2.`Addendum` AS `NameAddendum`,
          NULL AS `InformalNameString`,
          NULL AS `InformalNameString_language`,
          NULL AS `Code`,
          T2.`IsCurrent` AS `PreferredFlag`,
          NULL AS `NonFlag`,
          NULL AS `StoredUnderFlag`,
          NULL AS `ResultRole`,
          CASE 
            WHEN (T2.DeterminedDatePrecision = 1)
            THEN DATE_FORMAT(T2.DeterminedDate,\'%D %M %Y\')
            WHEN (T2.DeterminedDatePrecision = 2)
            THEN DATE_FORMAT(T2.DeterminedDate,\'%M %Y\')
            WHEN (T2.DeterminedDatePrecision = 3)
            THEN DATE_FORMAT(T2.DeterminedDate,\'%Y\')
            ELSE NULL
          END AS `Date_DateText`,
          NULL AS `Date_TimeZone`,
          DATE_FORMAT(T2.DeterminedDate,\'%Y-%m-%d\') AS `Date_ISODateTimeBegin`,
          NULL AS `Date_TimeOfDayBegin`,
          DAYOFYEAR(T2.DeterminedDate) AS `DayNumberBegin`,
          CASE 
            WHEN (T2.DeterminedDatePrecision = 1)
            THEN DATE_FORMAT(T2.DeterminedDate,\'%Y-%m-%d\')
            WHEN (T2.DeterminedDatePrecision = 2)
            THEN DATE_FORMAT(DATE_ADD(DATE_ADD(T2.DeterminedDate, INTERVAL 1 MONTH), INTERVAL -1 DAY),\'%Y-%m-%d\')
            WHEN (T2.DeterminedDatePrecision = 3)
            THEN DATE_FORMAT(DATE_ADD(DATE_ADD(T2.DeterminedDate, INTERVAL 1 YEAR), INTERVAL -1 DAY),\'%Y-%m-%d\')
            ELSE NULL
          END AS `Date_ISODateTimeEnd`,
          NULL AS `Date_TimeOfDayEnd`,
          CASE 
            WHEN (T2.DeterminedDatePrecision = 1)
            THEN DAYOFYEAR(T2.DeterminedDate)
            WHEN (T2.DeterminedDatePrecision = 2)
            THEN DAYOFYEAR(DATE_ADD(DATE_ADD(T2.DeterminedDate, INTERVAL 1 MONTH), INTERVAL -1 DAY))
            WHEN (T2.DeterminedDatePrecision = 3)
            THEN DAYOFYEAR(DATE_ADD(DATE_ADD(T2.DeterminedDate, INTERVAL 1 YEAR), INTERVAL -1 DAY))
            ELSE NULL
          END AS `Date_DayNumberEnd`,
          CASE
            WHEN (T2.DeterminedDate IS NULL)
            THEN NULL 
            ELSE 0 
          END AS `PeriodExplicit`,
          T2.`Method` AS `Method`,
          NULL AS `Method_language`,
          T2.`Remarks` AS `Notes`,
          NULL AS `VerificationLevel`,
          NULL AS `IdentificationHistory`
     FROM `svar_sourcedb_`.`collectionobject`         T1
          INNER JOIN `svar_sourcedb_`.`determination` T2 ON (T1.`CollectionObjectID` = T2.`CollectionObjectID`)
          INNER JOIN `t_tmp_colltaxa`                 T3 ON (T2.`TaxonID`            = T3.`TaxonID`)
          INNER JOIN `svar_sourcedb_`.`collection`    T4 ON (T1.`CollectionID`       = T4.`CollectionID`)
    WHERE T4.`Code` = \'', @collectioncode, '\';'),
  'svar_sourcedb_', @databasename);

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 4, NOW());


  SET @sql = REPLACE('
  CREATE OR REPLACE VIEW v_imp_biocase_identification_highertaxon
  AS
	SELECT T1.`Guid` AS `_identificationguid`,
           T2.`HigherTaxonName`,
           T2.`HigherTaxonRank`
      FROM `svar_sourcedb_`.`determination` T1
           INNER JOIN `v_imp_highertaxon` T2 ON (T1.`TaxonID` = T2.`TaxonID`);', 'svar_sourcedb_', @databasename);

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 5, NOW());


  -- CollectionObject
  
  SET @sql = REPLACE(CONCAT('
  CREATE OR REPLACE VIEW `v_imp_collectionobject_mappingfields`
  AS
    SELECT T2.`Guid` AS `CollectionObjectGuid`,
           T2.`text1`, T2.`text2`, T2.`text3`,T2.`YesNo1`, T2.`YesNo2`
      FROM `svar_sourcedb_`.`collection`                           AS T1
		   INNER JOIN `svar_sourcedb_`.`collectionobject`          AS T2 ON T1.`CollectionID`                = T2.`CollectionID`
     WHERE T1.`Code` = \'', @collectioncode, '\';'), 'svar_sourcedb_', @databasename);

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 6, NOW());


  -- CollectionObject-Attribute

  -- Günther Korb 20.09.2013
  -- Ergänzung neue Attribute für MeasurementsOrFacts
	
  SET @sql = REPLACE(CONCAT('
  CREATE OR REPLACE VIEW `v_imp_collectionobjectattribute_mappingfields`
  AS
    SELECT T2.`Guid` AS `CollectionObjectGuid`,
           T3.`Text1`, T3.`Text2`, T3.`Text3`, T3.`Text4`, T3.`Text5`, T3.`Text6`, T3.`Text7`, T3.`Text8`,
		   T3.`Text9`, T3.`Text10`, T3.`Text11`, T3.`Text12`, T3.`Text13`, T3.`Text14`, 
		   T3.`Number1`, T3.`Number2`, T3.`Number3`, T3.`Number4`, T3.`Number5`, T3.`Number6`	
      FROM `svar_sourcedb_`.`collection`                           AS T1
		   INNER JOIN `svar_sourcedb_`.`collectionobject`          AS T2 ON T1.`CollectionID`                = T2.`CollectionID`
		   INNER JOIN `svar_sourcedb_`.`collectionobjectattribute` AS T3 ON T2.`CollectionObjectAttributeID` = T3.`CollectionObjectAttributeID`
     WHERE T1.`Code` = \'', @collectioncode, '\';'), 'svar_sourcedb_', @databasename);

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 7, NOW());

-- Günther Korb 09.09.2013  
-- Multimediaobject
  
  SET @sql = REPLACE(CONCAT('
  CREATE OR REPLACE VIEW `v_imp_multimediaobject`
  AS
    SELECT 
		`T5`.`GUID` 						AS `_datasetguid`,
        `T4`.`GUID` 						AS `_unitguid`,
        `T1`.`CumulusID` 					AS `CumulusID`,
        `T2`.`GIN` 							AS `UnitID`,
        `T1`.`CumulusAssetName` 			AS `CumulusAssetName`,
        (CASE RIGHT(`T1`.`CumulusAssetName`, 4)
            WHEN \'.jpg\' THEN \'image/jpeg\'
            WHEN \'.tif\' THEN \'image/tiff\'
            WHEN \'.dng\' THEN \'image/dng\'
            ELSE \'unknown\'
        END) 								AS `Format`,
        CONCAT(\'http://coll.mfn-berlin.de/img/\',
                `T1`.`CumulusAssetName`) 	AS `FileURI`,
        CONCAT(\'http://coll.mfn-berlin.de/img/\',
                `T1`.`CumulusAssetName`) 	AS `ProductURI`,
        `T3`.`IPRText` 						AS `IPRText`,
        `T3`.`IPRDetails` 					AS `IPRDetails`,
        `T3`.`IPRURI` 						AS `IPRURI`,
        `T3`.`IPRText` 						AS `LicenseText`,
        `T3`.`IPRDetails` 					AS `LicenseDetails`,
        `T3`.`IPRURI` 						AS `LicenseURI`
      FROM
       `mfn_cumulus`.`t_cumulusasset` 				`T1`
        JOIN `mfn_cumulus`.`t_gin` 					`T2` ON `T1`.`CumulusID` 	= `T2`.`CumulusID`
        JOIN `svar_sourcedb_`.`collectionobject` 	`T4` ON `T2`.`GIN`			= `T4`.`ReservedText`
        JOIN `mfn_policies`.`t_ipr` 				`T3`
        JOIN `svar_sourcedb_`.`collection` 			`T5` ON `T5`.`CollectionID`	= `T4`.`CollectionID`
     WHERE T5.`Code` = \'', @collectioncode, '\';'), 'svar_sourcedb_', @databasename);

  
  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;


  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 8, NOW());

-- Günther Korb 18.09.2013  
-- Metadaten

  SET @sql = REPLACE(CONCAT('
  CREATE OR REPLACE VIEW `v_imp_metadata`
  AS
    SELECT `T1`.`Guid`                       		AS `_datasetguid`,			
		   `T6`.`DatasetGUID`						AS `DatasetGUID`,	
		   COALESCE(T6.`TechnicalContactName`,
		   (SELECT 
				T6.`FullName` 
			  FROM `v_imp_agent` T6 
					INNER JOIN `svar_sourcedb_`.`agent` 		T7 	ON T6.`AgentID` = T7.`AgentID`
			 WHERE T7.`CollectionTCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))								AS `TechnicalContactName`,
		   COALESCE(T6.`TechnicalContactEmail`,
		   (SELECT 
				T7.`Email` 
			  FROM `v_imp_agent` T6 
					INNER JOIN `svar_sourcedb_`.`agent` 		T7 	ON T6.`AgentID` = T7.`AgentID`
			 WHERE T7.`CollectionTCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))								AS `TechnicalContactEmail`,
		   COALESCE(T6.`TechnicalContactPhone`,
		   (SELECT 
				T8.`Phone1` 
			  FROM `v_imp_agent` T6 
					INNER JOIN `svar_sourcedb_`.`agent` 		T7 	ON T6.`AgentID` = T7.`AgentID`
					INNER JOIN `svar_sourcedb_`.`address` 		T8 	ON T7.`AgentID` = T8.`AgentID`
			 WHERE T7.`CollectionTCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))								AS `TechnicalContactPhone`,
           CONCAT(`T2`.`Name`,\' \',`T5`.`Address`,\' \',`T5`.`PostalCode`, \' \',`T5`.`City`,\' \',`T5`.`Country`) AS `TechnicalContactAddress`,			

		   COALESCE(T6.`ContentContactName`,
		   (SELECT 
				T6.`FullName` 
			  FROM `v_imp_agent` T6 
					INNER JOIN `svar_sourcedb_`.`agent` 		T7 	ON T6.`AgentID` = T7.`AgentID`
			 WHERE T7.`CollectionCCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))								AS `ContentContactName`,
		   COALESCE(T6.`ContentContactEmail`,
		   (SELECT 
				T7.`Email` 
			  FROM `v_imp_agent` T6 
					INNER JOIN `svar_sourcedb_`.`agent` 		T7 	ON T6.`AgentID` = T7.`AgentID`
			 WHERE T7.`CollectionCCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))								AS `ContentContactEmail`,
		   COALESCE(T6.`ContentContactPhone`,
		   (SELECT 
				T8.`Phone1` 
			  FROM `v_imp_agent` T6 
					INNER JOIN `svar_sourcedb_`.`agent` 		T7 	ON T6.`AgentID` = T7.`AgentID`
					INNER JOIN `svar_sourcedb_`.`address` 		T8 	ON T7.`AgentID` = T8.`AgentID`
			 WHERE T7.`CollectionCCID` = T1.`CollectionID` 
		  ORDER BY T6.`FullName`  
			 LIMIT 1))								AS `ContentContactPhone`,
           CONCAT(`T2`.`Name`,\' \',`T5`.`Address`,\' \',`T5`.`PostalCode`, \' \',`T5`.`City`,\' \',`T5`.`Country`) AS `ContentContactAddress`,			
		   `T6`.`OtherProviderUDDI`					AS `OtherProviderUDDI`,
           COALESCE(`T6`.`DatasetTitle`, 
					`T1`.`CollectionName`)			AS `DatasetTitle`,
           COALESCE(`T6`.`DatasetDetails`,
					`T1`.`Description`)				AS `DatasetDetails`,
           COALESCE(`T6`.`DatasetCoverage`,
					`T1`.`Scope`)          			AS `DatasetCoverage`,
           COALESCE(`T6`.`DatasetURI`, 
					`T1`.`WebSiteURI`)        		AS `DatasetURI`,
		   `T6`.`DatasetIconURI`					AS `DatasetIconURI`,	
		   `T6`.`DatasetVersionMajor`				AS `DatasetVersionMajor`,	
		   `T6`.`DatasetVersionMinor`				AS `DatasetVersionMinor`,	
		   `T6`.`DatasetCreators`					AS `DatasetCreators`,	
		   `T6`.`DatasetContributors`				AS `DatasetContributors`,	
		   `T6`.`DateCreated`						AS `DateCreated`,	
           COALESCE(`T6`.`DateModified`, 
					`T1`.`TimestampModified`)		AS `DateModified`,
		   `T6`.`OwnerOrganizationName`				AS `OwnerOrganizationName`,	
		   `T6`.`OwnerOrganizationAbbrev`			AS `OwnerOrganizationAbbrev`,	
		   `T6`.`OwnerContactPerson`				AS `OwnerContactPerson`,	
		   `T6`.`OwnerContactRole`					AS `OwnerContactRole`,	
		   `T6`.`OwnerAddress`						AS `OwnerAddress`,	
		   `T6`.`OwnerTelephone`					AS `OwnerTelephone`,	
		   `T6`.`OwnerEmail`						AS `OwnerEmail`,	
		   `T6`.`OwnerURI`							AS `OwnerURI`,	
		   `T6`.`OwnerLogoURI`						AS `OwnerLogoURI`,	
		   `T6`.`IPRText` 							AS `IPRText`,
		   `T6`.`IPRDetails` 						AS `IPRDetails`,
		   `T6`.`IPRURI` 							AS `IPRURI`,
		   `T6`.`CopyrightText` 					AS `CopyrightText`,
		   `T6`.`CopyrightDetails` 					AS `CopyrightDetails`,
		   `T6`.`CopyrightURI` 						AS `CopyrightURI`,
		   `T6`.`TermsOfUseText` 					AS `TermsOfUseText`,
		   `T6`.`TermsOfUseDetails` 				AS `TermsOfUseDetails`,
		   `T6`.`TermsOfUseURI` 					AS `TermsOfUseURI`,
		   `T6`.`DisclaimersText` 					AS `DisclaimersText`,
		   `T6`.`DisclaimersDetails` 				AS `DisclaimersDetails`,
		   `T6`.`DisclaimersURI` 					AS `DisclaimersURI`,
		   `T6`.`LicenseText` 						AS `LicenseText`,
		   `T6`.`LicenseDetails` 					AS `LicenseDetails`,
		   `T6`.`LicenseURI` 						AS `LicenseURI`,
		   `T6`.`AcknowledgementsText` 				AS `AcknowledgementsText`,
		   `T6`.`AcknowledgementsDetails` 			AS `AcknowledgementsDetails`,
		   `T6`.`AcknowledgementsURI` 				AS `AcknowledgementsURI`,
		   `T6`.`CitationsText` 					AS `CitationsText`,
		   `T6`.`CitationsDetails` 					AS `CitationsDetails`,
		   `T6`.`CitationsURI` 						AS `CitationsURI`,
           COALESCE(`T6`.`SourceInstitutionID`,
					`T2`.`Code`)					AS `SourceInstitutionID`,    
           COALESCE(`T6`.`SourceID`,
					`T1`.`Code`)					AS `SourceID`,               
		   COALESCE(T6.`RecordBasis`,
		   (SELECT
				T6.`Description`
			  FROM `svar_sourcedb_`.`collectionobject` T6
			 WHERE T6.`CollectionID` = T1.`CollectionID` 
			 LIMIT 1)) 								AS `RecordBasis`,
		   `T6`.`KindOfUnit` 						AS `KindOfUnit`
	  FROM `svar_sourcedb_`.`institution` T2 
		   INNER JOIN `svar_sourcedb_`.`division`   T3 			ON T2.`InstitutionID` 	= T3.`InstitutionID`
		   INNER JOIN `svar_sourcedb_`.`discipline` T4 			ON T3.`DivisionID` 		= T4.`DivisionID`
		   INNER JOIN `svar_sourcedb_`.`collection` T1 			ON T4.`DisciplineID` 	= T1.`DisciplineID`
		   INNER JOIN `svar_sourcedb_`.`address`    T5 			ON T2.`AddressID` 		= T5.`AddressID`,
		   `specify_biocasepreparer2`.`t_metadata_template` T6
	 WHERE T1.`Code` 				= \'',@collectioncode,'\'
	   AND T6.`MetadataTemplateID` 	= \'',@metadatatemplate,'\';'), 'svar_sourcedb_', @databasename);

  
  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;


  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareDataset', 9, NOW());



END

GO

DROP PROCEDURE IF EXISTS `p_prepareTaxa`;

GO

CREATE PROCEDURE `p_prepareTaxa`($collectioncode VARCHAR(128)
                               , $databasename   VARCHAR(128))
BEGIN
  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareTaxa',0,NOW());


  SET @sql = CONCAT('CREATE OR REPLACE VIEW `v_imp_agent`
					 AS
                       SELECT `AgentID`,
                              CONCAT(CONCAT(COALESCE(NULLIF(`FirstName`,\'\'),\' \'),\'\'),
                              CONCAT(COALESCE(NULLIF(`MiddleInitial`,\'\'),\' \'),\'\'), `LastName`) AS `FullName`
                         FROM `', $databasename ,'`.`agent`;');

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareTaxa',1,NOW());

  SET @sql = REPLACE(CONCAT('
  CREATE OR REPLACE VIEW `v_imp_taxon`
  AS
   SELECT T1.`TaxonTreeDefID`,
          T1.`TaxonID`,
          T1.`ParentID`,
          T1.`RankID`,
          CASE
            WHEN (T1.`RankID` <= 180)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 180)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 180)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 180)
            THEN T4.`Name`
            ELSE \'$$$Error$$$\'
          END AS `GenusOrMonomial`,
          CASE
            WHEN (T1.`RankID` = 180)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 180)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 180)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 180)
            THEN T4.`TaxonID`
            ELSE NULL
          END AS `GenusID`,
          CASE
            WHEN (T1.`RankID` = 190)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 190)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 190)
            THEN T3.`Name`
            ELSE \'\'
          END AS `Subgenus`,
          CASE
            WHEN (T1.`RankID` = 190)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 190)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 190)
            THEN T3.`TaxonID`
            ELSE NULL
          END AS `SubgenusID`,
          CASE
            WHEN (T1.`RankID` = 220)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 220)
            THEN T2.`Name`
            ELSE \'\'
          END AS `Species`,
          CASE
            WHEN (T1.`RankID` = 220)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 220)
            THEN T2.`TaxonID`
            ELSE NULL
          END AS `SpeciesID`,
          CASE
            WHEN (T1.`RankID` = 230)
            THEN T1.`Name`
            ELSE \'\'
          END AS `Subspecies`,
          CASE
            WHEN (T1.`RankID` = 230)
            THEN T1.`TaxonID`
            ELSE NULL
          END AS `SubpeciesID`,
          T1.`Author`,
          CASE
            WHEN (T1.`RankID` = 170)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 170)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 170)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 170)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 170)
            THEN T5.`Name`
            ELSE \'\'
          END AS `Subtribe`,
          CASE
            WHEN (T1.`RankID` = 170)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 170)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 170)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 170)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 170)
            THEN T5.`TaxonID`
            ELSE NULL
          END AS `SubtribeID`,
          CASE
            WHEN (T1.`RankID` = 160)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 160)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 160)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 160)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 160)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 160)
            THEN T6.`Name`
            ELSE \'\'
          END AS `Tribe`,
          CASE
            WHEN (T1.`RankID` = 160)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 160)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 160)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 160)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 160)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 160)
            THEN T6.`TaxonID`
            ELSE NULL
          END AS `TribeID`,
          CASE
            WHEN (T1.`RankID` = 150)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 150)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 150)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 150)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 150)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 150)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 150)
            THEN T7.`Name`
            ELSE \'\'
          END AS `Subfamily`,
          CASE
            WHEN (T1.`RankID` = 150)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 150)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 150)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 150)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 150)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 150)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 150)
            THEN T7.`TaxonID`
            ELSE NULL
          END AS `SubfamilyID`,
          CASE
            WHEN (T1.`RankID` = 140)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 140)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 140)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 140)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 140)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 140)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 140)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 140)
            THEN T8.`Name`
            ELSE \'\'
          END AS `Family`,
          CASE
            WHEN (T1.`RankID` = 140)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 140)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 140)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 140)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 140)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 140)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 140)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 140)
            THEN T8.`TaxonID`
            ELSE NULL
          END AS `FamilyID`,
          CASE
            WHEN (T1.`RankID` = 120)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 120)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 120)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 120)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 120)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 120)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 120)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 120)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 120)
            THEN T9.`Name`
            ELSE \'\'
          END AS `Infraorder`,
          CASE
            WHEN (T1.`RankID` = 120)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 120)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 120)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 120)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 120)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 120)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 120)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 120)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 120)
            THEN T9.`TaxonID`
            ELSE NULL
          END AS `InfraorderID`,
          CASE
            WHEN (T1.`RankID` = 110)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 110)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 110)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 110)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 110)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 110)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 110)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 110)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 110)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 110)
            THEN T10.`Name`
            ELSE \'\'
          END AS `Suborder`,
          CASE
            WHEN (T1.`RankID` = 110)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 110)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 110)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 110)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 110)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 110)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 110)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 110)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 110)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 110)
            THEN T10.`TaxonID`
            ELSE NULL
          END AS `SuborderID`,
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
            WHEN (T6.`RankID` = 100)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 100)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 100)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 100)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 100)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 100)
            THEN T11.`Name`
            ELSE \'\'
          END AS `Order`,
          CASE
            WHEN (T1.`RankID` = 100)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 100)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 100)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 100)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 100)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 100)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 100)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 100)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 100)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 100)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 100)
            THEN T11.`TaxonID`
            ELSE NULL
          END AS `OrderID`,
          CASE
            WHEN (T1.`RankID` = 90)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 90)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 90)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 90)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 90)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 90)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 90)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 90)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 90)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 90)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 90)
            THEN T11.`Name`
            WHEN (T12.`RankID` = 90)
            THEN T12.`Name`
            ELSE \'\'
          END AS `Superorder`,
          CASE
            WHEN (T1.`RankID` = 90)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 90)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 90)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 90)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 90)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 90)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 90)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 90)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 90)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 90)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 90)
            THEN T11.`TaxonID`
            WHEN (T12.`RankID` = 90)
            THEN T12.`TaxonID`
            ELSE NULL
          END AS `SuperorderID`,
          CASE
            WHEN (T1.`RankID` = 80)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 80)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 80)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 80)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 80)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 80)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 80)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 80)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 80)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 80)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 80)
            THEN T11.`Name`
            WHEN (T12.`RankID` = 80)
            THEN T12.`Name`
            WHEN (T13.`RankID` = 80)
            THEN T13.`Name`
            ELSE \'\'
          END AS `Infraclass`,
          CASE
            WHEN (T1.`RankID` = 80)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 80)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 80)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 80)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 80)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 80)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 80)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 80)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 80)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 80)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 80)
            THEN T11.`TaxonID`
            WHEN (T12.`RankID` = 80)
            THEN T12.`TaxonID`
            WHEN (T13.`RankID` = 80)
            THEN T13.`TaxonID`
            ELSE NULL
          END AS `InfraclassID`,
          CASE
            WHEN (T1.`RankID` = 70)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 70)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 70)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 70)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 70)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 70)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 70)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 70)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 70)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 70)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 70)
            THEN T11.`Name`
            WHEN (T12.`RankID` = 70)
            THEN T12.`Name`
            WHEN (T13.`RankID` = 70)
            THEN T13.`Name`
            WHEN (T14.`RankID` = 70)
            THEN T14.`Name`
            ELSE \'\'
          END AS `Subclass`,
          CASE
            WHEN (T1.`RankID` = 70)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 70)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 70)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 70)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 70)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 70)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 70)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 70)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 70)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 70)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 70)
            THEN T11.`TaxonID`
            WHEN (T12.`RankID` = 70)
            THEN T12.`TaxonID`
            WHEN (T13.`RankID` = 70)
            THEN T13.`TaxonID`
            WHEN (T14.`RankID` = 70)
            THEN T14.`TaxonID`
            ELSE NULL
          END AS `SubclassID`,
          CASE
            WHEN (T1.`RankID` = 60)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 60)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 60)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 60)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 60)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 60)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 60)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 60)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 60)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 60)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 60)
            THEN T11.`Name`
            WHEN (T12.`RankID` = 60)
            THEN T12.`Name`
            WHEN (T13.`RankID` = 60)
            THEN T13.`Name`
            WHEN (T14.`RankID` = 60)
            THEN T14.`Name`
            WHEN (T15.`RankID` = 60)
            THEN T15.`Name`
            ELSE \'\'
          END AS `Class`,
          CASE
            WHEN (T1.`RankID` = 60)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 60)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 60)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 60)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 60)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 60)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 60)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 60)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 60)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 60)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 60)
            THEN T11.`TaxonID`
            WHEN (T12.`RankID` = 60)
            THEN T12.`TaxonID`
            WHEN (T13.`RankID` = 60)
            THEN T13.`TaxonID`
            WHEN (T14.`RankID` = 60)
            THEN T14.`TaxonID`
            WHEN (T15.`RankID` = 60)
            THEN T15.`TaxonID`
            ELSE NULL
          END AS `ClassID`,
          CASE
            WHEN (T1.`RankID` = 50)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 50)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 50)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 50)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 50)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 50)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 50)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 50)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 50)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 50)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 50)
            THEN T11.`Name`
            WHEN (T12.`RankID` = 50)
            THEN T12.`Name`
            WHEN (T13.`RankID` = 50)
            THEN T13.`Name`
            WHEN (T14.`RankID` = 50)
            THEN T14.`Name`
            WHEN (T15.`RankID` = 50)
            THEN T15.`Name`
            WHEN (T16.`RankID` = 50)
            THEN T16.`Name`
            ELSE \'\'
          END AS `Superclass`,
          CASE
            WHEN (T1.`RankID` = 50)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 50)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 50)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 50)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 50)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 50)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 50)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 50)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 50)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 50)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 50)
            THEN T11.`TaxonID`
            WHEN (T12.`RankID` = 50)
            THEN T12.`TaxonID`
            WHEN (T13.`RankID` = 50)
            THEN T13.`TaxonID`
            WHEN (T14.`RankID` = 50)
            THEN T14.`TaxonID`
            WHEN (T15.`RankID` = 50)
            THEN T15.`TaxonID`
            WHEN (T16.`RankID` = 50)
            THEN T16.`TaxonID`
            ELSE NULL
          END AS `SuperclassID`,
          CASE
            WHEN (T1.`RankID` = 40)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 40)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 40)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 40)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 40)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 40)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 40)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 40)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 40)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 40)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 40)
            THEN T11.`Name`
            WHEN (T12.`RankID` = 40)
            THEN T12.`Name`
            WHEN (T13.`RankID` = 40)
            THEN T13.`Name`
            WHEN (T14.`RankID` = 40)
            THEN T14.`Name`
            WHEN (T15.`RankID` = 40)
            THEN T15.`Name`
            WHEN (T16.`RankID` = 40)
            THEN T16.`Name`
            WHEN (T17.`RankID` = 40)
            THEN T17.`Name`
            ELSE \'\'
          END AS `Subphylum`,
          CASE
            WHEN (T1.`RankID` = 40)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 40)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 40)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 40)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 40)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 40)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 40)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 40)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 40)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 40)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 40)
            THEN T11.`TaxonID`
            WHEN (T12.`RankID` = 40)
            THEN T12.`TaxonID`
            WHEN (T13.`RankID` = 40)
            THEN T13.`TaxonID`
            WHEN (T14.`RankID` = 40)
            THEN T14.`TaxonID`
            WHEN (T15.`RankID` = 40)
            THEN T15.`TaxonID`
            WHEN (T16.`RankID` = 40)
            THEN T16.`TaxonID`
            WHEN (T17.`RankID` = 40)
            THEN T17.`TaxonID`
            ELSE NULL
          END AS `SubphylumID`,
          CASE
            WHEN (T1.`RankID` = 30)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 30)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 30)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 30)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 30)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 30)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 30)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 30)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 30)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 30)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 30)
            THEN T11.`Name`
            WHEN (T12.`RankID` = 30)
            THEN T12.`Name`
            WHEN (T13.`RankID` = 30)
            THEN T13.`Name`
            WHEN (T14.`RankID` = 30)
            THEN T14.`Name`
            WHEN (T15.`RankID` = 30)
            THEN T15.`Name`
            WHEN (T16.`RankID` = 30)
            THEN T16.`Name`
            WHEN (T17.`RankID` = 30)
            THEN T17.`Name`
            WHEN (T18.`RankID` = 30)
            THEN T18.`Name`
            ELSE \'\'
          END AS `Phylum`,
          CASE
            WHEN (T1.`RankID` = 30)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 30)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 30)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 30)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 30)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 30)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 30)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 30)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 30)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 30)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 30)
            THEN T11.`TaxonID`
            WHEN (T12.`RankID` = 30)
            THEN T12.`TaxonID`
            WHEN (T13.`RankID` = 30)
            THEN T13.`TaxonID`
            WHEN (T14.`RankID` = 30)
            THEN T14.`TaxonID`
            WHEN (T15.`RankID` = 30)
            THEN T15.`TaxonID`
            WHEN (T16.`RankID` = 30)
            THEN T16.`TaxonID`
            WHEN (T17.`RankID` = 30)
            THEN T17.`TaxonID`
            WHEN (T18.`RankID` = 30)
            THEN T18.`TaxonID`
            ELSE NULL
          END AS `PhylumID`,
          CASE
            WHEN (T1.`RankID` = 10)
            THEN T1.`Name`
            WHEN (T2.`RankID` = 10)
            THEN T2.`Name`
            WHEN (T3.`RankID` = 10)
            THEN T3.`Name`
            WHEN (T4.`RankID` = 10)
            THEN T4.`Name`
            WHEN (T5.`RankID` = 10)
            THEN T5.`Name`
            WHEN (T6.`RankID` = 10)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 10)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 10)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 10)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 10)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 10)
            THEN T11.`Name`
            WHEN (T12.`RankID` = 10)
            THEN T12.`Name`
            WHEN (T13.`RankID` = 10)
            THEN T13.`Name`
            WHEN (T14.`RankID` = 10)
            THEN T14.`Name`
            WHEN (T15.`RankID` = 10)
            THEN T15.`Name`
            WHEN (T16.`RankID` = 10)
            THEN T16.`Name`
            WHEN (T17.`RankID` = 10)
            THEN T17.`Name`
            WHEN (T18.`RankID` = 10)
            THEN T18.`Name`
            WHEN (T19.`RankID` = 10)
            THEN T19.`Name`
            ELSE \'\'
          END AS `Kingdom`,
          CASE
            WHEN (T1.`RankID` = 10)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 10)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 10)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 10)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 10)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 10)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 10)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 10)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 10)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 10)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 10)
            THEN T11.`TaxonID`
            WHEN (T12.`RankID` = 10)
            THEN T12.`TaxonID`
            WHEN (T13.`RankID` = 10)
            THEN T13.`TaxonID`
            WHEN (T14.`RankID` = 10)
            THEN T14.`TaxonID`
            WHEN (T15.`RankID` = 10)
            THEN T15.`TaxonID`
            WHEN (T16.`RankID` = 10)
            THEN T16.`TaxonID`
            WHEN (T17.`RankID` = 10)
            THEN T17.`TaxonID`
            WHEN (T18.`RankID` = 10)
            THEN T18.`TaxonID`
            WHEN (T19.`RankID` = 10)
            THEN T19.`TaxonID`
            ELSE NULL
          END AS `KingdomID`,
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
            WHEN (T6.`RankID` = 0)
            THEN T6.`Name`
            WHEN (T7.`RankID` = 0)
            THEN T7.`Name`
            WHEN (T8.`RankID` = 0)
            THEN T8.`Name`
            WHEN (T9.`RankID` = 0)
            THEN T9.`Name`
            WHEN (T10.`RankID` = 0)
            THEN T10.`Name`
            WHEN (T11.`RankID` = 0)
            THEN T11.`Name`
            WHEN (T12.`RankID` = 0)
            THEN T12.`Name`
            WHEN (T13.`RankID` = 0)
            THEN T13.`Name`
            WHEN (T14.`RankID` = 0)
            THEN T14.`Name`
            WHEN (T15.`RankID` = 0)
            THEN T15.`Name`
            WHEN (T16.`RankID` = 0)
            THEN T16.`Name`
            WHEN (T17.`RankID` = 0)
            THEN T17.`Name`
            WHEN (T18.`RankID` = 0)
            THEN T18.`Name`
            WHEN (T19.`RankID` = 0)
            THEN T19.`Name`
            WHEN (T20.`RankID` = 0)
            THEN T20.`Name`
            ELSE \'\'
          END AS `Life`,
          CASE
            WHEN (T1.`RankID` = 0)
            THEN T1.`TaxonID`
            WHEN (T2.`RankID` = 0)
            THEN T2.`TaxonID`
            WHEN (T3.`RankID` = 0)
            THEN T3.`TaxonID`
            WHEN (T4.`RankID` = 0)
            THEN T4.`TaxonID`
            WHEN (T5.`RankID` = 0)
            THEN T5.`TaxonID`
            WHEN (T6.`RankID` = 0)
            THEN T6.`TaxonID`
            WHEN (T7.`RankID` = 0)
            THEN T7.`TaxonID`
            WHEN (T8.`RankID` = 0)
            THEN T8.`TaxonID`
            WHEN (T9.`RankID` = 0)
            THEN T9.`TaxonID`
            WHEN (T10.`RankID` = 0)
            THEN T10.`TaxonID`
            WHEN (T11.`RankID` = 0)
            THEN T11.`TaxonID`
            WHEN (T12.`RankID` = 0)
            THEN T12.`TaxonID`
            WHEN (T13.`RankID` = 0)
            THEN T13.`TaxonID`
            WHEN (T14.`RankID` = 0)
            THEN T14.`TaxonID`
            WHEN (T15.`RankID` = 0)
            THEN T15.`TaxonID`
            WHEN (T16.`RankID` = 0)
            THEN T16.`TaxonID`
            WHEN (T17.`RankID` = 0)
            THEN T17.`TaxonID`
            WHEN (T18.`RankID` = 0)
            THEN T18.`TaxonID`
            WHEN (T19.`RankID` = 0)
            THEN T19.`TaxonID`
            WHEN (T20.`RankID` = 0)
            THEN T20.`TaxonID`
            ELSE NULL
          END AS `LifeID`
     FROM `svar_sourcedb_`.`taxon` T1
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T2  ON (T1.`TaxonTreeDefID`  = T2.`TaxonTreeDefID`  AND T1.`ParentID`  =  T2.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T3  ON (T2.`TaxonTreeDefID`  = T3.`TaxonTreeDefID`  AND T2.`ParentID`  =  T3.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T4  ON (T3.`TaxonTreeDefID`  = T4.`TaxonTreeDefID`  AND T3.`ParentID`  =  T4.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T5  ON (T4.`TaxonTreeDefID`  = T5.`TaxonTreeDefID`  AND T4.`ParentID`  =  T5.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T6  ON (T5.`TaxonTreeDefID`  = T6.`TaxonTreeDefID`  AND T5.`ParentID`  =  T6.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T7  ON (T6.`TaxonTreeDefID`  = T7.`TaxonTreeDefID`  AND T6.`ParentID`  =  T7.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T8  ON (T7.`TaxonTreeDefID`  = T8.`TaxonTreeDefID`  AND T7.`ParentID`  =  T8.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T9  ON (T8.`TaxonTreeDefID`  = T9.`TaxonTreeDefID`  AND T8.`ParentID`  =  T9.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T10 ON (T9.`TaxonTreeDefID`  = T10.`TaxonTreeDefID` AND T9.`ParentID`  =  T10.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T11 ON (T10.`TaxonTreeDefID` = T11.`TaxonTreeDefID` AND T10.`ParentID` =  T11.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T12 ON (T11.`TaxonTreeDefID` = T12.`TaxonTreeDefID` AND T11.`ParentID` =  T12.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T13 ON (T12.`TaxonTreeDefID` = T13.`TaxonTreeDefID` AND T12.`ParentID` =  T13.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T14 ON (T13.`TaxonTreeDefID` = T14.`TaxonTreeDefID` AND T13.`ParentID` =  T14.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T15 ON (T14.`TaxonTreeDefID` = T15.`TaxonTreeDefID` AND T14.`ParentID` =  T15.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T16 ON (T15.`TaxonTreeDefID` = T16.`TaxonTreeDefID` AND T15.`ParentID` =  T16.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T17 ON (T16.`TaxonTreeDefID` = T17.`TaxonTreeDefID` AND T16.`ParentID` =  T17.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T18 ON (T17.`TaxonTreeDefID` = T18.`TaxonTreeDefID` AND T17.`ParentID` =  T18.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T19 ON (T18.`TaxonTreeDefID` = T19.`TaxonTreeDefID` AND T18.`ParentID` =  T19.`TaxonID`)
          LEFT OUTER JOIN `svar_sourcedb_`.`taxon` T20 ON (T19.`TaxonTreeDefID` = T20.`TaxonTreeDefID` AND T19.`ParentID` =  T20.`TaxonID`)
    WHERE (T1.`TaxonTreeDefID` = (SELECT D.`TaxonTreeDefID`
                                    FROM `svar_sourcedb_`.`collection`            C
                                         INNER JOIN `svar_sourcedb_`.`discipline` D ON (C.`DisciplineID` = D.`DisciplineID`)
                                   WHERE C.`Code` = \'', $collectioncode, '\'));
  '), 'svar_sourcedb_', $databasename);

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareTaxa',2,NOW());

  SET @sql = '
  CREATE OR REPLACE VIEW v_imp_highertaxon
  AS
   SELECT `TaxonID`,
          `kingdom` AS `HigherTaxonName`,
          \'kingdom\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`kingdom`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `phylum` AS `HigherTaxonName`,
          \'phylum\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`phylum`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `subphylum` AS `HigherTaxonName`,
          \'subphylum\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`subphylum`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `superclass` AS `HigherTaxonName`,
          \'superclass\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`superclass`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `class` AS `HigherTaxonName`,
          \'class\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`class`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `subclass` AS `HigherTaxonName`,
          \'subclass\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`subclass`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `superorder` AS `HigherTaxonName`,
          \'superorder\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`superorder`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `order` AS `HigherTaxonName`,
          \'order\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`order`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `suborder` AS `HigherTaxonName`,
          \'suborder\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`suborder`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `family` AS `HigherTaxonName`,
          \'family\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`family`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `subfamily` AS `HigherTaxonName`,
          \'subfamily\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`subfamily`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          `tribe` AS `HigherTaxonName`,
          \'tribe\' AS `HigherTaxonRank`
     FROM `t_tmp_colltaxa`
    WHERE (NULLIF(NULLIF(`tribe`,\'\'),\'?\') IS NOT NULL)
   UNION    
   SELECT `TaxonID`,
          CONCAT(`genusormonomial`,COALESCE(CONCAT(\' \',NULLIF(`subgenus`,\'\')),\'\')) AS `HigherTaxonName`,
          \'genusgroup\' AS `HigherTaxonRank`
     FROM t_tmp_colltaxa
    WHERE (RankID >= 180)
      AND (NULLIF(NULLIF(`genusormonomial`,\'\'),\'?\') IS NOT NULL);';

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareTaxa',3,NOW());


  TRUNCATE TABLE `t_tmp_colltaxa`;

  INSERT 
    INTO `t_tmp_colltaxa`
         SELECT *
           FROM v_imp_taxon;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareTaxa',4,NOW());
END

GO

DROP PROCEDURE IF EXISTS `p_prepareGeography`;

GO

CREATE PROCEDURE `p_prepareGeography`($collectioncode VARCHAR(128)
                                    , $databasename   VARCHAR(128))
BEGIN
  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareGeography',0,NOW());


  SET @sql = REPLACE(CONCAT('
  CREATE OR REPLACE VIEW `v_imp_geography`
  AS
    SELECT T1.`GeographyTreeDefID`,
           T1.`GeographyID`,
           T1.`ParentID`,
           T1.`RankID`,
           CASE
             WHEN (T1.`RankID` = 400)
             THEN T1.`Name`
             ELSE NULL
           END AS `County`,
           CASE
             WHEN (T1.`RankID` = 400)
             THEN T1.`GeographyID`
             ELSE NULL
           END AS `CountyID`,
           CASE
             WHEN (T1.`RankID` = 300)
             THEN T1.`Name`
             WHEN (T2.`RankID` = 300)
             THEN T2.`Name`
             ELSE NULL
           END AS `State`,
           CASE
             WHEN (T1.`RankID` = 300)
             THEN T1.`GeographyID`
             WHEN (T2.`RankID` = 300)
             THEN T2.`GeographyID`
             ELSE NULL
           END AS `StateID`,
           CASE
             WHEN (T1.`RankID` = 200)
             THEN T1.`Name`
             WHEN (T2.`RankID` = 200)
             THEN T2.`Name`
             WHEN (T3.`RankID` = 200)
             THEN T3.`Name`
             ELSE NULL
           END AS `Country`,
           CASE
             WHEN (T1.`RankID` = 200)
             THEN T1.`GeographyID`
             WHEN (T2.`RankID` = 200)
             THEN T2.`GeographyID`
             WHEN (T3.`RankID` = 200)
             THEN T3.`GeographyID`
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
             ELSE NULL
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
             ELSE NULL
           END AS `ContinentID`
      FROM `svar_sourcedb_`.`geography` T1
           LEFT OUTER JOIN `svar_sourcedb_`.`geography` T2 ON (T1.`GeographyTreeDefID` = T2.`GeographyTreeDefID` AND T1.`ParentID` = T2.`GeographyID`)
           LEFT OUTER JOIN `svar_sourcedb_`.`geography` T3 ON (T2.`GeographyTreeDefID` = T3.`GeographyTreeDefID` AND T2.`ParentID` = T3.`GeographyID`)
           LEFT OUTER JOIN `svar_sourcedb_`.`geography` T4 ON (T3.`GeographyTreeDefID` = T4.`GeographyTreeDefID` AND T3.`ParentID` = T4.`GeographyID`)
     WHERE (T1.`GeographyTreeDefID` = (SELECT D.`GeographyTreeDefID`
                                         FROM `svar_sourcedb_`.`collection`            C
                                              INNER JOIN `svar_sourcedb_`.`discipline` D ON (C.`DisciplineID` = D.`DisciplineID`)
										WHERE C.`Code` = \'', $collectioncode, '\'));
  '), 'svar_sourcedb_', $databasename);

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareGeography', 1, NOW());

  SET @sql = '
  CREATE OR REPLACE VIEW v_imp_geographynamedareas
  AS
    SELECT `GeographyID`,
           `state` AS `NamedArea`,
           \'state\' AS `AreaClass`
      FROM `t_tmp_geography`
     WHERE (NULLIF(NULLIF(`state`,\'\'),\'?\') IS NOT NULL)
    UNION    
    SELECT `GeographyID`,
           `county`,
           \'county\' 
      FROM `t_tmp_geography`
     WHERE (NULLIF(NULLIF(`county`,\'\'),\'?\') IS NOT NULL)
     FROM t_tmp_geography;';

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareGeography',2,NOW());


  TRUNCATE TABLE `t_tmp_geography`;

  INSERT 
    INTO `t_tmp_geography`
         SELECT *
           FROM v_imp_geography;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('p_prepareGeography',3,NOW());
END

GO

DROP PROCEDURE IF EXISTS `p_prepareLastedited`;

GO

CREATE PROCEDURE `p_prepareLastedited`($datasourceid INT)
BEGIN
  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('lastedited', 0, NOW());

  SET @databasename = (SELECT `database`
                         FROM `t_datasource`
                        WHERE (`datasourceid` = $datasourceid));

  SET @collectioncode = (SELECT `collectioncode`
                           FROM `t_datasource`
                          WHERE (`datasourceid` = $datasourceid));

  TRUNCATE TABLE `t_tmp_lastedited`;

  SET @sql = REPLACE('
  INSERT 
    INTO `t_tmp_lastedited`
         SELECT `CollectionObjectID`,
                `LastEditor`,
                `DateLastEdited`
           FROM (-- ROW_NUMBER per Partition: Brian Steffens
                 -- http://briansteffens.com/2011/07/19/row_number-partition-and-over-in-mysql/
                 SELECT @id := if(@lastid != `CollectionObjectID`, 1, @id + 1) as row_number,
                        @lastid := `CollectionObjectID` AS `CollectionObjectID`,
                        T1.`LastEditor`,
                        T1.`DateLastEdited`
                   FROM (SELECT `CollectionObjectID`,
                                COALESCE(I1.`ModifiedByAgentID`,I1.`CreatedByAgentID`)  AS `LastEditor`,
                                COALESCE(I1.`TimestampModified`,I1.`TimestampModified`) AS `DateLastEdited`
                           FROM `svar_sourcedb_`.`collectionobject`      I1
                                INNER JOIN `svar_sourcedb_`.`collection` I2 ON I1.`CollectionID` = I2.`CollectionID`
                          WHERE I2.`Code` = ?
                         UNION
                         SELECT `CollectionObjectID`,
                                COALESCE(I1.`ModifiedByAgentID`,I1.`CreatedByAgentID`),
                                COALESCE(I1.`TimestampModified`,I1.`TimestampModified`)
                           FROM `svar_sourcedb_`.`determination`          I1
                                INNER JOIN  `svar_sourcedb_`.`collection` I2 ON I1.`CollectionMemberID` = I2.`CollectionID`
                          WHERE I2.`Code` = ?
                         UNION
                         SELECT I1.`CollectionObjectID`,
                                COALESCE(I2.`ModifiedByAgentID`,I2.`CreatedByAgentID`),
                                COALESCE(I2.`TimestampModified`,I2.`TimestampModified`)
                           FROM `svar_sourcedb_`.`collectionobject`           I1
                                INNER JOIN `svar_sourcedb_`.`collectingevent` I2 ON I1.`CollectingEventID` = I2.`CollectingEventID`
                                INNER JOIN `svar_sourcedb_`.`collection`      I3 ON I1.`CollectionID`      = I3.`CollectionID`
                          WHERE I3.`Code` = ? 
                        ) T1,
                        (select @id := 0) T2,
                        (select @lastid := null) T3
                  ORDER BY `CollectionObjectID`, `datelastedited` DESC
                ) T0
          WHERE (row_number = 1);', 'svar_sourcedb_', @databasename);

  PREPARE $stmt FROM @sql;
  EXECUTE $stmt USING @collectioncode, @collectioncode, @collectioncode;
  DEALLOCATE PREPARE $stmt;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('lastedited', 1, NOW());
END

GO

DROP PROCEDURE IF EXISTS `p_SyncBiocaseIdentificationHighertaxon`;

GO

CREATE PROCEDURE `p_SyncBiocaseIdentificationHighertaxon`($datasourceid INT)
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLWARNING BEGIN END;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('IdentificationHighertaxon', 0, NOW());


  SET @databasename = (SELECT `database`
                         FROM `t_datasource`
                        WHERE (`datasourceid` = $datasourceid));

  SET @collectioncode = (SELECT `collectioncode`
                           FROM `t_datasource`
                          WHERE (`datasourceid` = $datasourceid));
  SET @datasetguid = (SELECT `guid`
                        FROM `v_imp_dataset`);

  TRUNCATE TABLE `t_tmp_biocase_identification_highertaxon`;

  INSERT 
    INTO `t_tmp_biocase_identification_highertaxon`
         SELECT *
           FROM `v_imp_biocase_identification_highertaxon`;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('IdentificationHighertaxon', 1, NOW());


  -- Synchronisation
  -- gelöschte Datensätze entfernen

  DELETE T1
    FROM `specify_biocase`.`t_biocase_identification_highertaxon` T1
         INNER JOIN `specify_biocase`.`t_biocase_identification` T3 
                 ON (T1.`_identificationguid` = T3.`_identificationguid`) 
         INNER JOIN `specify_biocase`.`t_biocase_unit` T4
                 ON (T3.`_unitguid` = T4.`_unitguid`) 
         LEFT OUTER JOIN  `t_tmp_biocase_identification_highertaxon` T2 
                      ON (T1.`_identificationguid` = T2.`_identificationguid`)
                     AND (T1.`HigherTaxonRank`     = T2.`HigherTaxonRank`)
   WHERE (T4.`_datasetguid` = @datasetguid)
     AND (T2.`_identificationguid` IS NULL);

  SET @deletedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('IdentificationHighertaxon', 2, NOW());


  -- geänderte Datensätze aktualisieren

  UPDATE `specify_biocase`.`t_biocase_identification_highertaxon` T1
         INNER JOIN `t_tmp_biocase_identification_highertaxon` T2 
                 ON (T1.`_identificationguid` = T2.`_identificationguid`)
                AND (T1.`HigherTaxonRank`     = T2.`HigherTaxonRank`)
     SET T1.`HigherTaxonName` = T2.`HigherTaxonName`
   WHERE (T1.`HigherTaxonName` <> T2.`HigherTaxonName`);

  SET @updatedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('IdentificationHighertaxon', 3, NOW());


  -- neue Datensätze anfügen

  INSERT 
    INTO `specify_biocase`.`t_biocase_identification_highertaxon`
         SELECT T1.*
           FROM `t_tmp_biocase_identification_highertaxon` T1
                LEFT OUTER JOIN `specify_biocase`.`t_biocase_identification_highertaxon` T2
                             ON (T1.`_identificationguid` = T2.`_identificationguid`)
                            AND (T1.`HigherTaxonRank`     = T2.`HigherTaxonRank`)
          WHERE (T2.`_identificationguid` IS NULL)
            AND (T1.`_identificationguid` IN (SELECT `_identificationguid`
                                                FROM `specify_biocase`.`t_biocase_identification`));

  SET @insertedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('IdentificationHighertaxon', 4, NOW());
END;

GO

DROP PROCEDURE IF EXISTS `p_SyncBiocaseIdentification`;

GO

CREATE PROCEDURE `p_SyncBiocaseIdentification`($datasourceid INT)
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLWARNING BEGIN END;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Identification', 0, NOW());

  SET @databasename = (SELECT `database`
                         FROM `t_datasource`
                        WHERE (`datasourceid` = $datasourceid));

  SET @collectioncode = (SELECT `collectioncode`
                           FROM `t_datasource`
                          WHERE (`datasourceid` = $datasourceid));
  SET @datasetguid = (SELECT `guid`
                        FROM `v_imp_dataset`);

  TRUNCATE TABLE `t_tmp_guid`;

  INSERT 
    INTO `t_tmp_guid` (`guid`)
         SELECT `_identificationguid`
           FROM `v_imp_biocase_identification`;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Identification', 1, NOW());

  
  TRUNCATE TABLE `t_tmp_biocase_identification`;

  INSERT 
    INTO `t_tmp_biocase_identification`
         SELECT *
           FROM `v_imp_biocase_identification`;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Identification', 2, NOW());


  -- Platzhalter Mapping
   

  -- Synchronisation
  -- gelöschte Datensätze entfernen

  DELETE 
    FROM `specify_biocase`.`t_biocase_identification`
   WHERE `_identificationguid` NOT IN (SELECT `guid`
                                         FROM `t_tmp_guid`)
     AND `_unitguid` IN (SELECT `_unitguid`
                           FROM `specify_biocase`.`t_biocase_unit`
                          WHERE `_datasetguid` = @datasetguid);
  
  SET @deletedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Identification', 3, NOW());


  -- geänderte Datensätze aktualisieren

  UPDATE `specify_biocase`.`t_biocase_identification` T1
         INNER JOIN `t_tmp_biocase_identification` T2 ON (T1.`_identificationguid` = T2.`_identificationguid`)
     SET T1.`ScientificName`                         = T2.`ScientificName`,
         T1.`FullScientificNameString`               = T2.`FullScientificNameString`,
         T1.`GenusOrMonomial`                        = T2.`GenusOrMonomial`,
         T1.`Subgenus`                               = T2.`Subgenus`,
         T1.`SpeciesEpithet`                         = T2.`SpeciesEpithet`,
         T1.`SubspeciesEpithet`                      = T2.`SubspeciesEpithet`,
         T1.`AuthorTeamOriginalAndYear`              = T2.`AuthorTeamOriginalAndYear`,
         T1.`AuthorTeamParenthesisAndYear`           = T2.`AuthorTeamParenthesisAndYear`,
         T1.`CombinationAuthorTeamAndYear`           = T2.`CombinationAuthorTeamAndYear`,
         T1.`Breed`                                  = T2.`Breed`,
         T1.`NamedIndividual`                        = T2.`NamedIndividual`,
         T1.`IdentificationQualifier`                = T2.`IdentificationQualifier`,
         T1.`IdentificationQualifier_insertionpoint` = T2.`IdentificationQualifier_insertionpoint`,
         T1.`NameAddendum`                           = T2.`NameAddendum`,
         T1.`InformalNameString`                     = T2.`InformalNameString`,
         T1.`InformalNameString_language`            = T2.`InformalNameString_language`,
         T1.`Code`                                   = T2.`Code`,
         T1.`PreferredFlag`                          = T2.`PreferredFlag`,
         T1.`NonFlag`                                = T2.`NonFlag`,
         T1.`StoredUnderFlag`                        = T2.`StoredUnderFlag`,
         T1.`ResultRole`                             = T2.`ResultRole`,
         T1.`Date_DateText`                          = T2.`Date_DateText`,
         T1.`Date_TimeZone`                          = T2.`Date_TimeZone`,
         T1.`Date_ISODateTimeBegin`                  = T2.`Date_ISODateTimeBegin`,
         T1.`Date_TimeOfDayBegin`                    = T2.`Date_TimeOfDayBegin`,
         T1.`DayNumberBegin`                         = T2.`DayNumberBegin`,
         T1.`Date_ISODateTimeEnd`                    = T2.`Date_ISODateTimeEnd`,
         T1.`Date_TimeOfDayEnd`                      = T2.`Date_TimeOfDayEnd`,
         T1.`Date_DayNumberEnd`                      = T2.`Date_DayNumberEnd`,
         T1.`PeriodExplicit`                         = T2.`PeriodExplicit`,
         T1.`Method`                                 = T2.`Method`,
         T1.`Method_language`                        = T2.`Method_language`,
         T1.`Notes`                                  = T2.`Notes`,
         T1.`VerificationLevel`                      = T2.`VerificationLevel`,
         T1.`IdentificationHistory`                  = T2.`IdentificationHistory`
   WHERE (T1.`_timestamp` <> T2.`_timestamp`);

  SET @updatedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Identification', 4, NOW());

  
  -- neue Datensätze anfügen

  INSERT
    INTO `specify_biocase`.`t_biocase_identification`
         SELECT * 
           FROM `t_tmp_biocase_identification`
   WHERE (`_unitguid` IN (SELECT `_unitguid`
                            FROM `specify_biocase`.`t_biocase_unit`))
     AND (`_identificationguid` NOT IN (SELECT `_identificationguid`
                                          FROM `specify_biocase`.`t_biocase_identification`));

  SET @insertedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Identification', 5, NOW());
END;

GO

DROP PROCEDURE IF EXISTS `p_SyncBiocaseSpecimenunitMark`;

GO

CREATE PROCEDURE `p_SyncBiocaseSpecimenunitMark`($datasourceid INT)
BEGIN
  DECLARE $attribute   VARCHAR(128);
  DECLARE $destfield   VARCHAR(128);
  DECLARE $fetchstatus INT DEFAULT (0);
  DECLARE $marktype    VARCHAR(255);
  DECLARE $prefix      VARCHAR(255);

  DECLARE recordset1 CURSOR 
      FOR SELECT `Attribute`,
                 `DestField`,
                 NULLIF(`Prefix`, ''),
				 NULLIF(`MarkType`, '')
            FROM `t_mapping_collectionobject`
           WHERE `DestTable` = 't_biocase_unit_specimenunit_mark'
             AND `CollectionCode` = @collectioncode;

  DECLARE recordset2 CURSOR 
      FOR SELECT `Attribute`,
                 `DestField`,
                 NULLIF(`Prefix`, ''),
				 NULLIF(`MarkType`, '')
            FROM `t_mapping_collectionobjectattribute`
           WHERE `DestTable` = 't_biocase_unit_specimenunit_mark'
             AND `CollectionCode` = @collectioncode;

  DECLARE CONTINUE HANDLER FOR SQLWARNING BEGIN END;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET $fetchstatus = 1;

  SET @datasetguid = (SELECT `guid`
                        FROM `v_imp_dataset`);

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('SpecimenunitMark', 0, NOW());

  TRUNCATE TABLE `t_tmp_guid`;

  TRUNCATE `t_tmp_biocase_specimenunit_mark`;

  -- CollectionObject

  OPEN recordset1;

  FETCH recordset1 
   INTO $attribute, $destfield, $prefix, $marktype;

  WHILE $fetchstatus = 0 DO
    SET @marktype = $marktype;
    SET @prefix   = $prefix;
    SET @sql = CONCAT('
    INSERT
      INTO `t_tmp_biocase_specimenunit_mark` (`_datasetguid`, `_unitguid`, `_markguid`, `MarkType`, `MarkText`)
           SELECT ?,
                  `CollectionObjectGuid`,
                  UUID(),
                  ?,
                  CONCAT(COALESCE(?, \'\'), `', $attribute, '`)
             FROM `v_imp_collectionobject_mappingfields`
            WHERE `', $attribute, '` IS NOT NULL;');

    PREPARE $stmt FROM @sql;
    EXECUTE $stmt USING @datasetguid, @marktype, @prefix;
    DEALLOCATE PREPARE $stmt;

    FETCH recordset1
     INTO $attribute, $destfield, $prefix, $marktype;
  END WHILE;

  CLOSE recordset1;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 2, NOW());


  -- CollectionObjectAttribute

  SET $fetchstatus = 0;

  OPEN recordset2;

  FETCH recordset2 
   INTO $attribute, $destfield, $prefix, $marktype;

  WHILE $fetchstatus = 0 DO
    SET @marktype = $marktype;
    SET @prefix   = $prefix;
    SET @sql = CONCAT('
    INSERT
      INTO `t_tmp_biocase_specimenunit_mark` (`_datasetguid`, `_unitguid`, `_markguid`, `MarkType`, `MarkText`)
           SELECT ?,
                  `CollectionObjectGuid`,
                  UUID(),
                  ?,
                  CONCAT(COALESCE(?, \'\'), `', $attribute, '`)
             FROM `v_imp_collectionobjectattribute_mappingfields`
            WHERE `', $attribute, '` IS NOT NULL;');

    PREPARE $stmt FROM @sql;
    EXECUTE $stmt USING @datasetguid, @marktype, @prefix;
    DEALLOCATE PREPARE $stmt;

    FETCH recordset2
     INTO $attribute, $destfield, $prefix, $marktype;
  END WHILE;

  CLOSE recordset2;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 3, NOW());


  -- Synchronisation
  -- alle Datensätze der Collection entfernen

  DELETE 
    FROM `specify_biocase`.`t_biocase_specimenunit_mark`
   WHERE `_datasetguid` = @datasetguid;

  SET @deletedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 4, NOW());
  

  -- Datensätze hinzufügen

  INSERT
    INTO `specify_biocase`.`t_biocase_specimenunit_mark`
         SELECT * 
           FROM `t_tmp_biocase_specimenunit_mark`;

  SET @insertedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 5, NOW());
END;

GO

DROP PROCEDURE IF EXISTS `p_SyncBiocaseUnit`;

GO

CREATE PROCEDURE `p_SyncBiocaseUnit`($datasourceid INT)
BEGIN
  DECLARE $attribute   VARCHAR(128);
  DECLARE $destfield   VARCHAR(128);
  DECLARE $prefix      VARCHAR(255);
  DECLARE $fetchstatus INT DEFAULT (0);

  DECLARE recordset1 CURSOR 
      FOR SELECT `Attribute`,
                 `DestField`,
				 NULLIF(`MarkType`, '')
            FROM `t_mapping_collectionobject`
           WHERE `DestTable` = 't_biocase_unit'
             AND `CollectionCode` = @collectioncode;

  DECLARE recordset2 CURSOR 
      FOR SELECT `attribute`,
                 `destfield`,
				 NULLIF(`prefix`, '')
            FROM `t_mapping_collectionobjectattribute`
           WHERE `desttable` = 't_biocase_unit'
             AND `collectioncode` = @collectioncode;

  DECLARE CONTINUE HANDLER FOR SQLWARNING BEGIN END;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET $fetchstatus = 1;

  SET @databasename = (SELECT `database`
                         FROM `t_datasource`
                        WHERE (`datasourceid` = $datasourceid));

  SET @collectioncode = (SELECT `collectioncode`
                           FROM `t_datasource`
                          WHERE (`datasourceid` = $datasourceid));
  SET @datasetguid = (SELECT `guid`
                        FROM `v_imp_dataset`);

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 0, NOW());

  TRUNCATE TABLE `t_tmp_guid`;

  INSERT 
    INTO `t_tmp_guid` (`guid`)
         SELECT `_unitguid`
           FROM `v_imp_biocase_unit`;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 1, NOW());

  TRUNCATE `t_tmp_biocase_unit`;

  INSERT
    INTO `t_tmp_biocase_unit`
         SELECT *
		   FROM `v_imp_biocase_unit`;


  -- CollectionObject

  OPEN recordset1;

  FETCH recordset1 
   INTO $attribute, $destfield, $prefix;

  WHILE $fetchstatus = 0 DO
    SET @prefix = $prefix;
    SET @sql = CONCAT('
    UPDATE `t_tmp_biocase_unit` T1
           INNER JOIN `v_imp_collectionobject_mappingfields` T2 ON (T1.`_unitguid` = T2.`CollectionObjectGuid`)
       SET T1.`', $destfield, '` = CONCAT(COALESCE(CONCAT(T1.`', $destfield, '`, \'; \'), \'\'), CONCAT(COALESCE(?, \'\'), T2.`', $attribute,'`))
     WHERE T2.`', $attribute,'` IS NOT NULL; 
    ');

    PREPARE $stmt FROM @sql;
    EXECUTE $stmt USING @prefix;
    DEALLOCATE PREPARE $stmt;

    FETCH recordset1
     INTO $attribute, $destfield, $prefix;
  END WHILE;

  CLOSE recordset1;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 2, NOW());


  -- CollectionObjectAttribute

  SET $fetchstatus = 0;

  OPEN recordset2;

  FETCH recordset2 
   INTO $attribute, $destfield, $prefix;

  WHILE $fetchstatus = 0 DO
    SET @prefix = $prefix;
    SET @sql = CONCAT('
    UPDATE `t_tmp_biocase_unit` T1
           INNER JOIN `v_imp_collectionobjectattribute_mappingfields` T2 ON (T1.`_unitguid` = T2.`CollectionObjectGuid`)
       SET T1.`', $destfield, '` = CONCAT(COALESCE(CONCAT(T1.`', $destfield, '`, \'; \'), \'\'), CONCAT(COALESCE(?, \'\'), T2.`', $attribute,'`))
     WHERE T2.`', $attribute,'` IS NOT NULL; 
    ');

    PREPARE $stmt FROM @sql;
    EXECUTE $stmt USING @prefix;
    DEALLOCATE PREPARE $stmt;

    FETCH recordset2
     INTO $attribute, $destfield, $prefix;
  END WHILE;

  CLOSE recordset2;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 3, NOW());


  -- Synchronisation
  -- gelöschte Datensätze entfernen

  DELETE 
    FROM `specify_biocase`.`t_biocase_unit`
   WHERE `_unitguid` NOT IN (SELECT `guid`
                               FROM `t_tmp_guid`)
     AND `_datasetguid` = @datasetguid;

  SET @deletedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 4, NOW());
  

  -- geänderte Datensätze aktualisieren

  UPDATE `specify_biocase`.`t_biocase_unit` T1
         INNER JOIN `t_tmp_biocase_unit` T2 ON (T1.`_unitguid` = T2.`_unitguid`)
     SET T1.`SourceInstitutionID`   = T2.`SourceInstitutionID`,
         T1.`SourceID`              = T2.`SourceID`,
         T1.`UnitID`                = T2.`UnitID`,
         T1.`UnitIDNumeric`         = T2.`UnitIDNumeric`,
         T1.`LastEditor`            = T2.`LastEditor`,
         T1.`DateLastEdited`        = T2.`DateLastEdited`,
         T1.`RecordBasis`           = T2.`RecordBasis`,
         T1.`CollectorsFieldNumber` = T2.`CollectorsFieldNumber`,
         T1.`Sex`                   = T2.`Sex`,
         T1.`Age`                   = T2.`Age`,
         T1.`RecordURI`             = T2.`RecordURI`,
         T1.`Notes`                 = T2.`Notes`
   WHERE (T1.`DateLastEdited` <> T2.`DateLastEdited`);

  SET @updatedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 5, NOW());
  

  -- neue Datensätze hinzufügen

  INSERT
    INTO `specify_biocase`.`t_biocase_unit`
         SELECT * 
           FROM `t_tmp_biocase_unit`
   WHERE (`_unitguid` NOT IN (SELECT `_unitguid`
                                FROM `specify_biocase`.`t_biocase_unit`));

  SET @insertedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Unit', 6, NOW());
END;

GO

-- Günther Korb 10.09.2013
-- Multimediaobjekte

DROP PROCEDURE IF EXISTS `p_SyncBiocaseMultimediaObject`;

GO

CREATE PROCEDURE `p_SyncBiocaseMultimediaObject`($datasourceid INT)
BEGIN

  SET @databasename = 	(SELECT `database`
                           FROM `t_datasource`
                          WHERE (`datasourceid` = $datasourceid));

  SET @collectioncode = (SELECT `collectioncode`
                           FROM `t_datasource`
                          WHERE (`datasourceid` = $datasourceid));
  SET @datasetguid = 	(SELECT `guid`
                           FROM `v_imp_dataset`);

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('MultiMediaObject', 0, NOW());

 
  TRUNCATE `t_tmp_biocase_multimediaobject`;

  INSERT INTO `t_tmp_biocase_multimediaobject`  
		SELECT `_datasetguid`, `_unitguid`, UUID() AS `_mmoguid`,
						`CumulusID`, `UnitID`, `CumulusAssetName`, `Format`, `FileURI`, 
						`ProductURI`, `IPRText`, `IPRDetails`, `IPRURI`,
						`LicenseText`, `LicenseDetails`, `LicenseURI`
          FROM v_imp_multimediaobject;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('MultiMediaObject', 1, NOW());

  -- Synchronisation
  -- alle Datensätze der Collection entfernen

  DELETE 
    FROM `specify_biocase`.`t_biocase_multimediaobject`
   WHERE `_datasetguid` = @datasetguid;

  SET @deletedrecords = ROW_COUNT();

  -- Datensätze hinzufügen

  INSERT
    INTO `specify_biocase`.`t_biocase_multimediaobject`
         SELECT * 
           FROM `t_tmp_biocase_multimediaobject`;

  SET @insertedrecords = ROW_COUNT();

END

GO

DROP PROCEDURE IF EXISTS `p_SyncBiocaseMetadata`;

-- Günther Korb 18.09.2013
-- Metadaten

GO

CREATE PROCEDURE `p_SyncBiocaseMetadata`($datasourceid INT)
BEGIN

  SET @databasename   = (SELECT `database`
                           FROM `t_datasource`
                          WHERE (`datasourceid` = $datasourceid));

  SET @collectioncode = (SELECT `collectioncode`
                           FROM `t_datasource`
                          WHERE (`datasourceid` = $datasourceid));
  SET @datasetguid    = (SELECT `guid`
                           FROM `v_imp_dataset`);

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Metadata', 0, NOW());

 
  TRUNCATE `t_tmp_biocase_metadata`;

  INSERT INTO `t_tmp_biocase_metadata`  
		SELECT *
          FROM v_imp_metadata;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Metadata', 1, NOW());

  -- Synchronisation
  -- alle Datensätze der Collection entfernen

  DELETE 
    FROM `specify_biocase`.`t_biocase_metadata`
   WHERE `_datasetguid` = @datasetguid;

  SET @deletedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Metadata', 2, NOW());

  -- Datensätze hinzufügen

  INSERT
    INTO `specify_biocase`.`t_biocase_metadata`
         SELECT * 
           FROM `t_tmp_biocase_metadata`;

  SET @insertedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('Metadata', 3, NOW());

END

GO

DROP PROCEDURE IF EXISTS `p_SyncBiocaseMeasurementsOrFacts`;

-- Günther Korb 23.09.2013
-- MeasurementsOrFacts

GO

CREATE PROCEDURE `p_SyncBiocaseMeasurementsOrFacts`($datasourceid INT)

BEGIN
  DECLARE $attribute   VARCHAR(128);
  DECLARE $destfield   VARCHAR(128);
  DECLARE $fetchstatus INT DEFAULT (0);
  DECLARE $parameter    VARCHAR(255);


  DECLARE recordset1 CURSOR 
      FOR SELECT `Attribute`,
                 `DestField`,
				 NULLIF(`Parameter`, '')
            FROM `t_mapping_collectionobjectattribute`
           WHERE `DestTable` = 't_biocase_measurementsorfacts'
             AND `CollectionCode` = @collectioncode;

  DECLARE CONTINUE HANDLER FOR SQLWARNING BEGIN END;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET $fetchstatus = 1;

  SET @datasetguid = (SELECT `guid`
                        FROM `v_imp_dataset`);
 
 SET @databasename = (SELECT `database`
                        FROM `t_datasource`
                       WHERE (`datasourceid` = $datasourceid));


  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('MeasurementsOrFacts', 0, NOW());

  TRUNCATE TABLE `t_tmp_guid`;

  TRUNCATE `t_tmp_biocase_measurementsorfacts`;

  -- CollectionObjectAttribute

  OPEN recordset1;

  FETCH recordset1 
   INTO $attribute, $destfield, $parameter;

  WHILE $fetchstatus = 0 DO
    SET @parameter = $parameter;
    SET @sql = CONCAT('
    INSERT
      INTO `t_tmp_biocase_measurementsorfacts` (`_datasetguid`, `_unitguid`, `_mofguid`, `ABCDConcept`, `Parameter`, `LowerValue`, `IsQuantitative`)
           SELECT ?,
                  `CollectionObjectGuid`,
                  UUID(),
				  \'Unit\',	
                  ?,
                  `', $attribute, '`,
				  CASE
					WHEN (SELECT T1.data_type 
							FROM information_schema.columns T1 
						   WHERE T1.`table_schema` = \'', @databasename,'\' 
							 AND T1.`table_name` = \'collectionobjectattribute\' 
							 AND T1.`column_name` = `', $attribute,'`) IN (\'int\', \'float\', \'tinyint\')
				    THEN \'TRUE\' 
				    ELSE \'FALSE\' 
				  END
             FROM `v_imp_collectionobjectattribute_mappingfields`
            WHERE `', $attribute, '` IS NOT NULL;');

    PREPARE $stmt FROM @sql;
    EXECUTE $stmt USING @datasetguid, @parameter;
    DEALLOCATE PREPARE $stmt;

    FETCH recordset1
     INTO $attribute, $destfield, $parameter;
  END WHILE;

  CLOSE recordset1;

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('MeasurementsOrFacts', 1, NOW());


  -- Synchronisation
  -- alle Datensätze der der MeasurementsOrFacts entfernen, die zur Collection und zum Konzept 'Unit' gehören

  DELETE 
    FROM `specify_biocase`.`t_biocase_measurementsorfacts`
   WHERE `_datasetguid` = @datasetguid
		 AND ABCDConcept = 'Unit';

  SET @deletedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('MeasurementsOrFacts', 2, NOW());
  

  -- Datensätze hinzufügen

  INSERT
    INTO `specify_biocase`.`t_biocase_measurementsorfacts`
         SELECT * 
           FROM `t_tmp_biocase_measurementsorfacts`;

  SET @insertedrecords = ROW_COUNT();

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES ('MeasurementsOrFacts', 3, NOW());


END


GO

DROP PROCEDURE IF EXISTS `p_syncDatasource`;

GO

CREATE PROCEDURE `p_syncDatasource`($datasourceid INT)
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLWARNING BEGIN END;

  SET @databasename = (SELECT `database`
                         FROM `t_datasource`
                        WHERE (`datasourceid` = $datasourceid));

  SET @collectioncode = (SELECT `collectioncode`
                           FROM `t_datasource`
                          WHERE (`datasourceid` = $datasourceid));

  SET @dbalias = (SELECT `alias`
                    FROM `t_datasource`
                   WHERE (`datasourceid` = $datasourceid));

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES (CONCAT('datasource ', @dbalias, ' start'), 0, NOW());

  CALL `p_prepareDataset`($datasourceid);
  CALL `p_prepareLastedited`($datasourceid);
  CALL `p_prepareTaxa`(@collectioncode, @databasename);

  CALL `p_syncBiocaseUnit`($datasourceid);
  CALL `p_syncBiocaseIdentification`($datasourceid);
  CALL `p_syncBiocaseIdentificationHigherTaxon`($datasourceid);
  CALL `p_SyncBiocaseSpecimenunitMark`($datasourceid);
  CALL `p_SyncBiocaseMultimediaobject`($datasourceid);
  CALL `p_SyncBiocaseMetadata`($datasourceid);
  CALL `p_SyncBiocaseMeasurementsOrFacts`($datasourceid);

  INSERT INTO `t_steps` (`Object`, `StepID`, `Timestamp`) VALUES (CONCAT('datasource ', @dbalias, ' end'), 1, NOW());
END

GO

DROP PROCEDURE IF EXISTS `p_execJob`;

GO

CREATE PROCEDURE `p_execJob`()
BEGIN
  DECLARE $fetchstatus  INT DEFAULT 0;
  DECLARE $datasourceid INT;

  DECLARE recordset CURSOR 
      FOR SELECT `datasourceid`
            FROM `t_datasource`
           WHERE `enabled` = true;

  DECLARE CONTINUE HANDLER FOR SQLWARNING BEGIN END;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET $fetchstatus = 1;

  OPEN recordset;

  FETCH recordset 
   INTO $datasourceid;

  WHILE $fetchstatus = 0 DO
    CALL `p_SyncDatasource`($datasourceid);

    FETCH recordset 
     INTO $datasourceid;
  END WHILE;

  CLOSE recordset;
END

GO

CALL `p_execJob`();

GO


DELIMITER ;
