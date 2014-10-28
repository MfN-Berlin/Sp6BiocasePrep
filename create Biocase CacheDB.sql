DELIMITER GO 

CREATE DATABASE IF NOT EXISTS `specify_biocase`;

GO

USE `specify_biocase`;

GO

DROP TABLE IF EXISTS `t_biocase_unit`;

GO

CREATE TABLE IF NOT EXISTS `t_biocase_unit`
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

  CONSTRAINT `pk_biocase_unit_01` PRIMARY KEY (`_unitguid`),
  CONSTRAINT `uq_biocase_unit_01` UNIQUE (`SourceInstitutionID`, `SourceID`, `UnitID`),

  KEY `ix_biocase_unit_01` (`_datasetguid`, `_unitguid`),
  KEY `ix_biocase_unit_02` (`UnitID`, `_unitguid`),
  KEY `ix_biocase_unit_03` (`DateLastEdited`, `_unitguid`)

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
  KEY `ix_biocase_identification_07` (`SubspeciesEpithet`,`_unitguid`)
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
  CONSTRAINT `uq_biocase_specimenunit_mark_01` UNIQUE (`_markguid`)
)

GO

DELIMITER ;
