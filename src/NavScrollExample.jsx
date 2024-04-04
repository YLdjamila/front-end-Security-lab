import React, { useState } from 'react';
import { Button, Menu } from 'antd';
import { MenuOutlined, CloseOutlined } from '@ant-design/icons';
import Container from 'react-bootstrap/Container';
import Form from 'react-bootstrap/Form';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';
import NavDropdown from 'react-bootstrap/NavDropdown';
import img from './images/logo2.jpg';




function NavScrollExample() {
  const [menuVisible, setMenuVisible] = useState(false);
  const [contentWidth, setContentWidth] = useState("100%");

  const toggleMenu = () => {
    setMenuVisible(!menuVisible);
    setContentWidth(menuVisible ? "100%" : "calc(100% - 200px)"); 
  };

  const closeMenu = () => {
    setMenuVisible(false);
    setContentWidth("100%");
  };

  return (
    <div>
      <Navbar expand="lg" className="bg-body-tertiary">
        <Container fluid style={{ width: contentWidth, transition: "width 0.2s" }}>
          {menuVisible ? (
            <Button
              icon={<CloseOutlined />}
              onClick={toggleMenu}
              style={{ position: 'absolute', left: 0, top: '50%', transform: 'translateY(-50%)', zIndex: 1001 }}
            />
          ) : (
            <Button
              icon={<MenuOutlined />}
              onClick={toggleMenu}
              style={{ position: 'absolute', left: 0, top: '50%', transform: 'translateY(-50%)', zIndex: 1001 }}
            />
          )}
          <Navbar.Brand href="#" className={menuVisible ? "menu-open" : ""}>
          <img 
    src={img}
    width="200"
    height="40"
    className="d-inline-block align-top"
    style={{ 
      marginLeft: menuVisible ? '90px' : '40px', 
    }}
    alt="Pharmacy Management System Logo"
  />
            
          </Navbar.Brand>
          <Navbar.Toggle aria-controls="navbarScroll" />
          <Navbar.Collapse id="navbarScroll">
            <Nav className="me-auto my-2 my-lg-0" style={{ maxHeight: '100px' }} navbarScroll>
              <Nav.Link href="#action1">Home</Nav.Link>
              <Nav.Link href="#action2">Shop</Nav.Link>
              <NavDropdown title="About" id="navbarScrollingDropdown">
                <NavDropdown.Item href="#action3">Action</NavDropdown.Item>
                <NavDropdown.Item href="#action4">Another action</NavDropdown.Item>
                <NavDropdown.Divider />
                <NavDropdown.Item href="#action5">Something else here</NavDropdown.Item>
              </NavDropdown>
              <Nav.Link href="#" disabled>
                More
              </Nav.Link>
            </Nav>

            <Button  size="sm" className="ms-2" style={{backgroundColor:'#007bff', color: 'white' }}>
              Se connecter
            </Button>
            
            <Button  size="sm" className="ms-2" style={{backgroundColor:'#007bff', color: 'white' }}>
              S'identifier
            </Button>
          </Navbar.Collapse>
        </Container>
      </Navbar>

      {menuVisible && <div className="menu-layer" onClick={closeMenu}></div>} {}
      
      <Menu
        mode="inline"
        style={{
          width: 200,
          position: 'fixed',
          left: 0,
          top: 0,
          bottom: 0,
          zIndex: 1000, 
          display: menuVisible ? 'block' : 'none',
        }}
        inlineCollapsed={!menuVisible}
        theme="dark"
      >
        <Menu.Item key="close" onClick={closeMenu}>
         
        </Menu.Item>
        <Menu.Item key="1">Navigation One</Menu.Item>
        <Menu.Item key="2">Navigation Two</Menu.Item>
        <Menu.Item key="3">Navigation Three</Menu.Item>
      </Menu>
    </div>
  );
}

export default NavScrollExample;
