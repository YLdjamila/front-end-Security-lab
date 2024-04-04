import React from 'react';

import FormExample from './NavScrollExample';
import CardExample from './CardExample';
import NavBar from './NavBar';
import 'bootstrap/dist/css/bootstrap.min.css';

import Pages from './Pages';
import Carousel from './MyCarousel.jsx';

function App() {
    return (
        <div className="App">
            <div style={{ width: '100%', marginBottom: '20px' }}>
                <FormExample/>

            </div>
            <NavBar/>
            <Carousel />

            <div style={{ display: 'flex', flexWrap: 'wrap' }}>
                <div style={{ flex: '0 0 33.333%', maxWidth: '33.333%' }}>
                    <CardExample/>
                </div>
                <div style={{ flex: '0 0 33.333%', maxWidth: '33.333%' }}>
                    <CardExample/>
                </div>
                <div style={{ flex: '0 0 33.333%', maxWidth: '33.333%' }}>
                    <CardExample/>
                </div>
                <div style={{ flex: '0 0 33.333%', maxWidth: '33.333%' }}>
                    <CardExample/>
                </div>
                <div style={{ flex: '0 0 33.333%', maxWidth: '33.333%' }}>
                    <CardExample/>
                </div>
                <div style={{ flex: '0 0 33.333%', maxWidth: '33.333%' }}>
                    <CardExample/>
                </div>
                <div style={{ flex: '0 0 33.333%', maxWidth: '33.333%' }}>
                    <CardExample/>
                </div>
                <div style={{ flex: '0 0 33.333%', maxWidth: '33.333%' }}>
                    <CardExample/>
                </div>
                <div style={{ flex: '0 0 33.333%', maxWidth: '33.333%' }}>
                    <CardExample/>
                </div>
            </div>
            <Pages/>
        </div>
    );
}

export default App;
