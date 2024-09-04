CREATE OR REPLACE FUNCTION bantam.update_geometry()
	RETURNS trigger
	LANGUAGE 'plpgsql'
	COST 100
	VOLATILE NOT LEAKPROOF
AS $$
BEGIN
	IF (TG_OP = 'INSERT') THEN
		NEW.wkb_geometry = bantam.ST_MakePoint(NEW.geo_lon, NEW.geo_lat);
	END IF;
	RETURN NEW;
END
$$;

CREATE TRIGGER ins_wkb_geometry_bantam
	BEFORE INSERT
	ON bantam.bantam_call_logs
	FOR EACH ROW
	EXECUTE PROCEDURE bantam.update_geometry();
	