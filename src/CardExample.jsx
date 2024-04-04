import React, { useState } from 'react';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import FavoriteBorderIcon from '@mui/icons-material/FavoriteBorder';
import FavoriteIcon from '@mui/icons-material/Favorite'; // Import filled heart icon

function CardExample({ menuVisible }) {
  const [isHovered, setIsHovered] = useState(false);
  const [isFavorite, setIsFavorite] = useState(false); // State to track if the card is favorited

  const handleMouseEnter = () => {
    setIsHovered(true);
  };

  const handleMouseLeave = () => {
    setIsHovered(false);
  };

  const toggleFavorite = () => {
    setIsFavorite(!isFavorite); 
  };

  const marginLeft = menuVisible ? '200px' : '5%'; 

  return (
    <div className="d-flex justify-content-center align-items-center" style={{ marginTop: '50px', marginLeft: marginLeft, marginRight: '5%', marginBottom: '2%' }}>
      <Card
        style={{
          width: '18rem',
          transform: isHovered ? 'scale(1.05)' : 'scale(1)',
          transition: 'transform 0.3s ease-in-out',
        }}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
      >
        <Card.Img variant="top" src="holder.js/100px180" />
        <Card.Body >
          <Card.Title>titre</Card.Title>
          <Card.Text>
            la description
          </Card.Text>
          <Button variant="primary">Voir l'article</Button>
          {isFavorite ? ( 
            <FavoriteIcon style={{ color: 'red', marginLeft: '120px', cursor: 'pointer' }} onClick={toggleFavorite} />
          ) : ( 
            <FavoriteBorderIcon style={{ marginLeft: '120px', cursor: 'pointer' }} onClick={toggleFavorite} />
          )}
        </Card.Body>
      </Card>
    </div>
  );
}

export default CardExample;
