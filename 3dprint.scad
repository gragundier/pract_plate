$fn = 200;
//droplet(center=true);
//regular_hexagon();
//rounded_rectangular_prism();

module droplet(
    d = 8,
    h = 20,
    r = 4,
    center = false,
) {
        r = d/2;
        il = r/2*sqrt(2); //camera inlet length
        union() {
            if (center==true) {
            translate([-il, 0, 0])
                rotate([0,0,45])
                    cube([r, r, h], center=true);
            }
            else {
                translate([-il, 0, h/2])
                rotate([0,0,45])
                    cube([r, r, h], center=true);
            }
            cylinder(d=d, h = h, center=center);
        }
}

module regular_hexagon(
height = 10,
thickness = 10,
) {
    union() {
        cube([thickness, thickness/sqrt(3), height], center=true);
        rotate([0,0,60])
            cube([thickness, thickness/sqrt(3), height], center=true);
        rotate([0,0,-60])
            cube([thickness, thickness/sqrt(3), height], center=true);
    }
}

module rounded_rectangular_prism( 
    spec = [55, 55, 2],
    rounded_edge_radius = 1.5,
    center=true,
) {
    cube([spec[1], spec[0]-rounded_edge_radius*2, spec[2]], center=center);
        cube([spec[1]-rounded_edge_radius*2, spec[0], spec[2]], center=center);
        translate([spec[1]/2-rounded_edge_radius, spec[0]/2-rounded_edge_radius, 0])
            cylinder(r=rounded_edge_radius, h=spec[2], center=center, $fn=200);
        translate([-(spec[1]/2-rounded_edge_radius), spec[0]/2-rounded_edge_radius, 0])
            cylinder(r=rounded_edge_radius, h=spec[2], $fn=200, center=center);
        translate([-(spec[1]/2-rounded_edge_radius), -(spec[0]/2-rounded_edge_radius), 0])
            cylinder(r=rounded_edge_radius, h=spec[2], $fn=200, center=center);
        translate([spec[1]/2-rounded_edge_radius, -(spec[0]/2-rounded_edge_radius), 0])
            cylinder(r=rounded_edge_radius, h=spec[2], $fn=200, center=center);
}