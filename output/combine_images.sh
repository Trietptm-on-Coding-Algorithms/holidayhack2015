convert factory_cam_1.png factory_cam_2.png -fx "(((255*u)&(255*(1-v)))|((255*(1-u))&(255*v)))/255" out1.png
convert out1.png factory_cam_3.png -fx "(((255*u)&(255*(1-v)))|((255*(1-u))&(255*v)))/255" out2.png
convert out2.png factory_cam_4.png -fx "(((255*u)&(255*(1-v)))|((255*(1-u))&(255*v)))/255" out3.png
convert out3.png factory_cam_5.png -fx "(((255*u)&(255*(1-v)))|((255*(1-u))&(255*v)))/255" out4.png
convert out4.png camera_feed_overlap_error.png -fx "(((255*u)&(255*(1-v)))|((255*(1-u))&(255*v)))/255" output.png
display output.png
