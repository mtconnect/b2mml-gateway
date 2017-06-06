DROP TABLE IF EXISTS VwGPManufacturingOrderProcesses;
CREATE TABLE VwGPManufacturingOrderProcesses (
       mo_id 	       varchar(31) NOT NULL,
       sequence_id     char(11) NOT NULL,
       parallel_seq_id char(11) NULL,
       next_seq_id     char(11) NULL,
       routing_description char(101) NULL,
       wc_id 	       char(11) NULL,
       wc_description  char(31) NULL,
       operation_id    char(7) NULL,
       machine_id      char(11) NOT NULL,
       setup_hrs       numeric(19, 5) NULL,
       machine_hrs     numeric(19, 5) NULL,
       run_hrs	       numeric(19, 5) NULL,
       labor_hrs       numeric(19, 5) NULL,
       cycle_hrs       numeric(19, 5) NULL,
       notes	       text NULL,
       closed_date     datetime NULL,
       closed_by       char(31) NULL,
       done_flag       tinyint
);

CREATE INDEX gpmop_i1 ON VwGPManufacturingOrderProcesses (mo_id DESC);
CREATE INDEX gpmop_i2 ON VwGPManufacturingOrderProcesses (wc_id DESC);

DROP TABLE IF EXISTS VwGPManufacturingOrderTransactions;
CREATE TABLE VwGPManufacturingOrderTransactions (
     eid       	            char(15) NOT NULL,
     last_name		    char(21) NULL,
     first_name		    char(15) NULL,
     datatype_id	    smallint NOT NULL,
     mo_id		    char(31) NOT NULL,
     job_id		    char(31) NULL,
     item_id		    char(31) NULL,
     item_description	    char(101) NULL,
     sequence_id	    char(11) NOT NULL,
     description	    char(101) NULL,
     labor_code		    char(11) NOT NULL,
     start_date		    datetime NOT NULL,
     start_time		    datetime NOT NULL,
     finish_date	    datetime NOT NULL,
     finish_time	    datetime NOT NULL,
     LABCODEDESC_I	    char(31) NOT NULL,
     LABCODEPAYCODESEL_I    smallint NOT NULL,
     elapsed_hrs	    numeric(19,5) NOT NULL,
     complete_qty	    numeric(19,5) NOT NULL,
     reject_qty		    numeric(19,5) NOT NULL,
     change_date	    datetime NOT NULL,
     user_id		    char(15) NOT NULL,
     labor_cost		    numeric(19,5) NOT NULL,
     setup_flag		    tinyint NOT NULL,
     cb_flag		    tinyint NOT NULL,
     POSTABLE_I		    tinyint NOT NULL,
     MFGNOTEINDEX_I   numeric(19,5) NOT NULL,
     fixed_ohead_cost	    numeric(19,5) NOT NULL,
     variable_ohead_cost    numeric(19,5) NOT NULL,
     DEX_ROW_ID		    int NOT NULL
);

CREATE INDEX gpmot_i1 ON VwGPManufacturingOrderTransactions (eid DESC);
CREATE INDEX gpmot_i2 ON VwGPManufacturingOrderTransactions (mo_id DESC);
CREATE INDEX gpmot_i3 ON VwGPManufacturingOrderTransactions (item_id DESC);

DROP TABLE IF EXISTS VwGPManufacturingOrders;
CREATE TABLE VwGPManufacturingOrders (
     mo_id               varchar(31) NULL,
     job_id	         char(31) NOT NULL,
     mo_type		 smallint NOT NULL,
     item_id		 char(31) NOT NULL,
     item_description	 char(101) NULL,
     bom_id		 char(15) NOT NULL,
     bom_rev		 char(51) NOT NULL,
     bom_type		 smallint NOT NULL,
     routing_id		 char(31) NOT NULL,
     routing_rev	 char(51) NOT NULL,
     drawing_id		 char(31) NULL,
     drawing_rev	 varchar(10) NULL,
     drawing_description varchar(40) NULL,
     end_qty		 numeric(19,5) NOT NULL,
     start_qty		 numeric(19,5) NOT NULL,
     start_date		 datetime NOT NULL,
     end_date		 datetime NOT NULL,
     uom_id		 char(11) NULL,
     standard_qty	 numeric(19,5) NULL,
     shipping_uom	 smallint NULL
);

CREATE INDEX gpmo_i1 ON VwGPManufacturingOrders (mo_id DESC);
CREATE INDEX gpmo_i2 ON VwGPManufacturingOrders (item_id DESC);
CREATE INDEX gpmo_i3 ON VwGPManufacturingOrders (job_id DESC);
