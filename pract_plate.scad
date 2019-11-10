use <3dprint.scad>;

$fn=200;
difference() {
    pract_plate(plate_bed = [100, 100, 12.5], thread_count = [4,4,3]);
    //translate([0,0,12.5])
        //cube([500,500, 10], center=true);
}

module pract_plate(
    custom_coordinates = [],
    thread_size = 3,
    tolerance = 0.2,
    plate_bed  = [150, 150, 12.5],
    plate_spread = [25, 25, 2.5+2.4/2],
    thread_count  = [6, 6, 3],
    hexagon_height = 2.4,
    hexagon_thickness = 5.4,
    hexagon_uc = .2,
    plate_thickness = 2.5,
    hexagon_casing_additional_thickness = 2.5,
    truss_thickness = 2.5,
    plate_modifier = [0,0,6.25],
    connector_thread_size = 3,
    connector_count = 3,
    connector_height = 6,
    connector_drill_depth = 6, 
    connector_spread = 25
) {
    true_hexagon_height = hexagon_height + hexagon_uc;
    true_hexagon_thickness = hexagon_thickness + hexagon_uc;
    hexagon_casing_thickness = true_hexagon_thickness+hexagon_casing_additional_thickness;
    
    //plate_modifier = [ for (x = [0:2]) axis_plate_modifier(plate_spread[x], thread_count[x])];
    //echo(plate_modifier);
    
    difference() {
        union() {
            plate_bed_shell(plate_bed, plate_thickness, truss_thickness);
            
            //Each node needs to be placed in a casing, so this generates that.
            hex_casing( plate_bed, thread_count, plate_spread, hexagon_height, hexagon_thickness, hexagon_uc, thread_size, hexagon_casing_additional_thickness, plate_modifier);
            truss_network( plate_bed, thread_count, plate_spread, hexagon_casing_thickness, plate_modifier, truss_thickness);
        }
        hex_nut_insert_and_threading( thread_count, plate_spread, hexagon_height, hexagon_thickness, hexagon_uc, thread_size, tolerance, plate_modifier);
        for ( z = [0:90:360] ) {
            rotate([ 0, 0, z])
                simple_connector(plate_bed, connector_thread_size, connector_drill_depth, connector_count, connector_height, connector_spread);
        }
    }
}

module hex_nut_insert_and_threading(
    thread_count = [6,6,2],
    plate_spread = [25,25,5],
    hexagon_height = 2.4,
    hexagon_thickness = 5.4,
    hexagon_uc = .2,
    thread_size = 3,
    tolerance = 0.2,
    plate_modifier = [0,0,0]
) {
    true_hexagon_height = hexagon_height + hexagon_uc;
    true_hexagon_thickness = hexagon_thickness + hexagon_uc;
    //hexagon_casing_thickness = true_hexagon_thickness+hexagon_casing_additional_thickness;
    //echo(plate_modifier);
    for(x = [-(thread_count[0]-1)/2:(thread_count[0]-1)/2]) {
            for (y = [-(thread_count[1]-1)/2:(thread_count[1]-1)/2]) {
                for (z = [-(thread_count[2]-1)/2:(thread_count[2]-1)/2]) {
                    translate([x*plate_spread[0]+plate_modifier[0], y*plate_spread[1]+plate_modifier[1], z*plate_spread[2]+plate_modifier[2]])
                        union() {
                            cylinder(h = 200, d = thread_size+tolerance, center=true);
                            regular_hexagon(true_hexagon_height, true_hexagon_thickness);
                        }
                }
            }
        }
    
}


module truss_network(
    plate_bed = [150, 150, 12.5],
    thread_count = [6,6,2],
    plate_spread = [25,25,5],
    hexagon_casing_thickness = 5, 
    plate_modifier = [0, 0, 0],
    truss_thickness = 2.5
) {
    //echo("truss: ");
    //echo(plate_modifier);
    for(x = [-(thread_count[0]-1)/2:(thread_count[0]-1)/2]) {
        for (y = [-(thread_count[1]-1)/2:(thread_count[1]-1)/2]) {
            translate([x*plate_spread[0]+plate_modifier[0], y*plate_spread[1]+plate_modifier[1], plate_bed[2]/2])
                union() {
                    cube([plate_spread[0], truss_thickness, plate_bed[2]], center=true);
                    cube([truss_thickness, plate_spread[1], plate_bed[2]], center=true);
            }
        }
    }
}

module  hex_casing(
    plate_bed = [150, 150, 2.5],
    thread_count = [6,6,2],
    plate_spread = [25,25,5],
    hexagon_height = 2.4,
    hexagon_thickness = 5.4,
    hexagon_uc = .2,
    thread_size = 3,
    hexagon_casing_additional_thickness = 2.5,
    plate_modifier = [0,0,0]
) {
    true_hexagon_height = hexagon_height + hexagon_uc;
    true_hexagon_thickness = hexagon_thickness + hexagon_uc;
    hexagon_casing_thickness = true_hexagon_thickness+hexagon_casing_additional_thickness;
    for(x = [-(thread_count[0]-1)/2:(thread_count[0]-1)/2]) {
                for (y = [-(thread_count[1]-1)/2:(thread_count[1]-1)/2]) {
                    translate([x*plate_spread[0]+plate_modifier[0], y*plate_spread[1]+plate_modifier[1], plate_bed[2]/2])
                        union() {
                            regular_hexagon(plate_bed[2], hexagon_casing_thickness);
                    }
                }
            }
}

module plate_bed_shell(
    plate_bed  = [150, 150, 12.5],
    plate_thickness = 2.5,
    truss_thickness = 2.5
) {
    translate([0,0,plate_bed[2]-plate_thickness/2])
        cube([plate_bed[0], plate_bed[1], plate_thickness], center=true);
    translate([0, plate_bed[1]/2-truss_thickness/2, plate_bed[2]/2])
        cube([plate_bed[0], truss_thickness, plate_bed[2]], center=true);
    translate([0, -(plate_bed[1]/2-truss_thickness/2), plate_bed[2]/2])
        cube([plate_bed[0], truss_thickness, plate_bed[2]], center=true);
    translate([plate_bed[0]/2-truss_thickness/2, 0, plate_bed[2]/2])
        cube([truss_thickness, plate_bed[1], plate_bed[2]], center=true);
    translate([-(plate_bed[0]/2-truss_thickness/2), 0, plate_bed[2]/2])
        cube([truss_thickness, plate_bed[1], plate_bed[2]], center=true);
}

function axis_plate_modifier(axis_plate_spread, axis_thread_count) = (axis_thread_count % 2 == 0) ? 0 : 0;

module recessed_hole(
    )
{
    
}

module connector_top(
    plate_bed = [150, 150, 12.5],
    plate_thickness = 2.5,
    connector_thickness = 5,
    connector_thread_size = 3
) {
    
}

module simple_connector(
    plate_bed = [150, 150, 12.5],
    connector_thread_size = 3,
    drill_depth = 5,
    connector_count = 3,
    connector_height = 6,
    connector_spread = 50
    ) {
    //echo("simple connector");
    //echo(connector_count);
    for (y = [-(connector_count-1)/2:(connector_count-1)/2]) {
        //echo(y);
        translate([plate_bed[0]/2-drill_depth, y*connector_spread, connector_height])
            rotate([0, 90, 0])
                droplet(d = connector_thread_size, h = drill_depth+0.2);
    }
}