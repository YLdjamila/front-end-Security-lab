import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Container from 'react-bootstrap/Container';

function NavBar() {
  return (
    <Container className="d-flex justify-content-center align-items-center" style={{ marginTop: '20px' }}>
      <Form className="d-flex" style={{ fontSize: '1rem' }}>
        <Form.Control
          type="search"
          placeholder="Que chercher-vous?"
          className="me-2"
          aria-label="Search"
          style={{ height: '50px', width: '500px', fontSize: '1rem' }}
        />
        <Button variant="outline-success" size="sm" style={{ height: '50px', fontSize: '1 rem' }}>
          Rechercher
        </Button>
      </Form>
    </Container>
  );
}

export default NavBar;
