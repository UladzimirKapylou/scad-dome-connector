frame_tube_diameter = 5;
node_tube_diameter = 10;
tube_wall_thickness = 0.15;
connection_height = 5;
cone_height = 0.6;
connection_wall_thickness = 0.41;
connection_floor_thickness = 0.0;
strip_thickness = 0.3;
strip_element_thickness = 0.4;
ground_strip_element_thickness = 0.7;
strip_element_distance = 0.2;
connector_count = 6;
connector_diameter_adjust = -0.1;
generate_fixtures = true;
fixture_diameter = 0.4;
fixture_count_in_row = 4;
fixture_row_angle = [30,60];
fixture_first_row_distance = 1;
fixture_rows_distance = 1;
// roof=234+115; // for 5 // look at faces section
roof = 197+215; // for 6
side=404;
sphere_part = 5/9;

$fn=50;
tube_diameter = frame_tube_diameter + connector_diameter_adjust;
node_tube_radius = node_tube_diameter / 2;
connection_diameter = tube_diameter - tube_wall_thickness * 2;
strip_length = connector_count * tube_diameter;
strip_width = frame_tube_diameter;
a_bit = $preview ? 0.001 : 0;

r = side / 2 / sin(360 / connector_count / 2);
echo(roof=roof, side=side, r=r);
assert(roof > r, "Roof should be longer than radius. Please double/triple check roof and side values");
angle = acos(r/roof);

node_tube_clean_radius = node_tube_radius - strip_element_thickness;
pivot_center = node_tube_clean_radius / sin(angle);
big_base = node_tube_clean_radius * 2 * tan(360 / connector_count / 2);
normal_side_angle = (connector_count - 2) / connector_count * 180;
rotation_angle = adj_angle(angle, angle, normal_side_angle);

echo(angle=angle);
echo(rotation_angle=rotation_angle);
echo(pivot_center=pivot_center);
echo(big_base=big_base);

//ground_connector_5();
connectors_test();
//connector();

module connectors_test() {
    normal_side_angle = 90;
    big_base = node_tube_clean_radius + 1;
    rotation_angle = 0;

    echo(angle=angle);
    echo(rotation_angle=rotation_angle);
    echo(pivot_center=pivot_center);
    echo(big_base=big_base);

    for (d = [-2:2], f = [-2:2]) {
        fixture = fixture_diameter + 0.1 * f;
        connection = connection_diameter + 0.1 * d;
        
        translate([big_base * d, strip_width * f, 0])
        connector_element(rotation_angle, rotation_angle, big_base, fixture_diameter = fixture, connection_diameter = connection);
    }
}

module connector() {
    r = side / 2 / sin(360 / connector_count / 2);
    assert(roof > r, "Roof should be longer than radius. Please double/triple check roof and side values");
    angle = acos(r/roof);

    normal_side_angle = (connector_count - 2) / connector_count * 180;
    big_base = node_tube_clean_radius * 2 * tan(180 / 6);
    rotation_angle = adj_angle(angle, angle, normal_side_angle);

    echo(angle=angle);
    echo(rotation_angle=rotation_angle);
    echo(pivot_center=pivot_center);
    echo(big_base=big_base);

    connector_element(0, rotation_angle, big_base, clip = "left")
    connector_element(rotation_angle, rotation_angle, big_base)
    connector_element(rotation_angle, rotation_angle, big_base)
    connector_element(rotation_angle, rotation_angle, big_base)
    connector_element(rotation_angle, rotation_angle, big_base)
    connector_element(rotation_angle, 0, big_base, clip = "right");
}

module ground_connector_5() {
    r = side / 2 / sin(360 / 6 / 2);
    assert(roof > r, "Roof should be longer than radius. Please double/triple check roof and side values");
    angle = acos(r/roof);
    echo(angle_for_ground=angle);

    normal_side_angle = 120;
    ground_angle = -2.5;//90 - 180 * sphere_part;
    big_base = node_tube_clean_radius * 2 * tan(180 / 6);
    ground_base = 2 * big_base * cos(30);
    rotation_angle = adj_angle(angle, angle, normal_side_angle);
    echo(angle=angle);
    echo(rotation_angle=rotation_angle);
    echo(pivot_center=pivot_center);
    echo(big_base=big_base);
    echo(ground_angle=ground_angle);

    connector_element(0, rotation_angle, big_base, clip = "left")
    connector_element(rotation_angle, rotation_angle, big_base)
    connector_element(rotation_angle, adj_angle(angle, ground_angle, normal_side_angle), big_base)
    connector_element(adj_angle(ground_angle, angle, 90), adj_angle(ground_angle, angle, 90), ground_base, thickness=ground_strip_element_thickness)
    connector_element(adj_angle(angle, ground_angle, normal_side_angle), rotation_angle, big_base)
    connector_element(rotation_angle, 0, big_base, clip = "right");
}

function adj_angle(face_angle, next_face_angle, angle_between_faces) =
    let(vertical_strip_width = 10, // any value. It just helps calculating
        face_width = vertical_strip_width / cos(face_angle),
        next_face_width = vertical_strip_width / cos(next_face_angle),
        face_distance = face_width * sin(face_angle),
        next_face_distance = next_face_width * sin(next_face_angle),
        next_face_rotation = angle_between_faces - 90, // againgst 90 degrees
        remaining_face_distance = face_distance - next_face_distance * sin(next_face_rotation),
        remaining_next_face_distance = next_face_distance * cos(next_face_rotation),
        big_base_diff = remaining_next_face_distance - remaining_face_distance * tan(next_face_rotation),
        angle = atan(big_base_diff / face_width))
//    echo()
//    echo(vertical_strip_width=vertical_strip_width)
//    echo(face_width=face_width)
//    echo(next_face_width=next_face_width)
//    echo(face_distance=face_distance)
//    echo(next_face_distance=next_face_distance)
//    echo(next_face_rotation=next_face_rotation)
//    echo(remaining_face_distance=remaining_face_distance)
//    echo(remaining_next_face_distance=remaining_next_face_distance)
//    echo(big_base_diff=big_base_diff)
//    echo(angle=angle)
    angle;

module connector_element(angle_left, angle_right, big_base, draw = true, clip, thickness=strip_element_thickness, fixture_diameter = fixture_diameter, connection_diameter = connection_diameter) {
    if (draw) {
        small_base_left_diff= strip_width * tan(angle_left);
        small_base_right_diff = strip_width * tan(angle_right);

        big_base_left = clip == "left" ? 0 : big_base / 2;
        big_base_right = clip == "right" ? 0 : big_base / 2;

        small_base_left = big_base_left - small_base_left_diff;
        small_base_right = big_base_right - small_base_right_diff;
        
        rotate([0,0, -angle_left])
        translate([small_base_left + small_base_right, 0, 0]) 
        rotate([0,0, -angle_right])
        children();
        
        rotate([0,0, -angle_left])
        translate([small_base_left, 0, 0])
        connector_element_itself(small_base_left, big_base_left, big_base_right, small_base_right, thickness, fixture_diameter, connection_diameter);
    } else {
        children();
    }
}    

module connector_element_itself(small_base_left, big_base_left, big_base_right, small_base_right, thickness, fixture_diameter, connection_diameter) {
    clip_left = small_base_left == 0 && big_base_left == 0;
    clip_right = small_base_right == 0 && big_base_right == 0;
    
    connector_base(small_base_left, big_base_left, big_base_right, small_base_right, thickness);
    translate([0, frame_tube_diameter / 2, thickness - a_bit])
        tube_with_floor(height = connection_height - cone_height + a_bit, thickness = connection_wall_thickness, floor_thickness = connection_floor_thickness)
        clip(clip_left, clip_right)
        circle(d=connection_diameter);
    
    cone_angle = 10;
    cone_offset = cone_height * tan(cone_angle);
    translate([0, frame_tube_diameter / 2, thickness + connection_height - cone_height - a_bit])
        difference() {
            hull() {
                linear_extrude(a_bit)
                    clip(clip_left, clip_right)
                    circle(d=connection_diameter);
                translate([0,0,cone_height])
                    linear_extrude(a_bit)
                    clip(clip_left, clip_right)
                    offset(-cone_offset)
                    circle(d=connection_diameter);
            }
            hull() {
                translate([0,0,-a_bit])
                    linear_extrude(a_bit + a_bit)
                    offset(-connection_wall_thickness)
                    clip(clip_left, clip_right)
                    circle(d=connection_diameter);
                translate([0,0,cone_height + a_bit])
                    linear_extrude(a_bit)
                    offset(-connection_wall_thickness)
                    clip(clip_left, clip_right)
                    offset(-cone_offset)
                    circle(d=connection_diameter);
                }
        }
    // render() // remove render artifacts
    translate([0, frame_tube_diameter / 2, thickness + fixture_first_row_distance + a_bit])
    clip_volume(clip_left, clip_right)
    add_fixtures(connection_diameter, fixture_diameter);
}

module add_fixtures(connection_diameter, fixture_diameter) {
    if (generate_fixtures) {
        for (row=[0:len(fixture_row_angle)-1]) {
            for (i=[1:fixture_count_in_row]) {
                rotate([0,0,fixture_row_angle[row] + i * 90])
                translate([0, -connection_diameter / 2, fixture_rows_distance * row])
                fixture(fixture_diameter);
            }
        }
    }
}

module fixture(fixture_diameter) {
    difference() {
        sphere(d=fixture_diameter, $fn=10);
        translate([0,0, -fixture_diameter]) cube(fixture_diameter * 2, center=true);
        translate([0, connection_diameter / 2 + 0.1, -fixture_diameter / 2]) cylinder(d=connection_diameter, h=fixture_diameter);
    }
}

module clip(clip_left, clip_right) {
    difference() {
        children();
        if (clip_left) {
            translate([-connection_diameter, -connection_diameter / 2, 0])
            square(connection_diameter);
        } else if (clip_right) {
            translate([0, -connection_diameter / 2, 0])
            square(connection_diameter);
        }
    }
}

module clip_volume(clip_left, clip_right) {
    difference() {
        children();
        if (clip_left) {
            translate([-connection_diameter*2 - a_bit, -connection_diameter, -a_bit])
            cube(connection_diameter*2);
        } else if (clip_right) {
            translate([a_bit, -connection_diameter, -a_bit])
            cube(connection_diameter*2);
        }
    }
}

module connector_base(small_base_left, big_base_left, big_base_right, small_base_right, thickness) {
    color("orange")
    linear_extrude(strip_thickness)
        polygon([[small_base_right, 0], [big_base_right, strip_width], [-big_base_left, strip_width], [-small_base_left, 0]]);
    element_small_base_left = max(0, small_base_left - strip_element_distance / 2);
    element_big_base_left = max(0, big_base_left - strip_element_distance / 2);
    element_small_base_right = max(0, small_base_right - strip_element_distance / 2);
    element_big_base_right = max(0, big_base_right - strip_element_distance / 2);
    color("Yellow")
    translate([0,0,strip_thickness])
    linear_extrude(thickness - strip_thickness)
        polygon([[element_small_base_right, 0], [element_big_base_right, strip_width], [-element_big_base_left, strip_width], [-element_small_base_left, 0]]);
}

module tube_with_floor(height, thickness, floor_thickness) {
    tube(height, thickness) children();
    linear_extrude(floor_thickness) children();
}

module tube(height, thickness) {
    linear_extrude(height) tube_profile(thickness) children();
}

module tube_profile(thickness) {
    difference() {
        children();
        offset(-thickness)
            children();
    }    
}