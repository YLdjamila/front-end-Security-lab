import React from 'react';
import { Carousel as AntCarousel } from 'antd'; // Rename Carousel to AntCarousel
import img1 from './images/med1.jpg';
import img2 from './images/med2.jpg';
import img3 from './images/med3.jpg';
import img4 from './images/med4.jpg';

const contentStyle = {
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  height: '200px',
  background: '#364d79',
};

function MyCarousel() {
  return (
    <AntCarousel autoplay autoplaySpeed={2000} style={{ marginTop: '20px' }}>
      <div>
        <img src={img1} alt="pic1" style={{ ...contentStyle, objectFit: 'cover', width: '100%' }} />
      </div>
      <div>
        <img src={img2} alt="pic2" style={{ ...contentStyle, objectFit: 'cover', width: '100%' }} />
      </div>
      <div>
        <img src={img3} alt="pic3" style={{ ...contentStyle, objectFit: 'cover', width: '100%' }} />
      </div>
      <div>
        <img src={img4} alt="pic4" style={{ ...contentStyle, objectFit: 'cover', width: '100%' }} />
      </div>
    </AntCarousel>
  );
}

export default MyCarousel;
