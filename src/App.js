import './App.css';
import React, {useState} from 'react';
import Header from './Header.jsx';
import Produits from './Produits';
import Card from './Card'



function App() {

    const [movieName, setMovieName] = useState('')
    const [review, setReview] = useState('')

  return (
      <div className="App">
          <Card/>
        <h1>Pharmacie</h1>


          <div className="form" >
              <Header/>
              <label>Movie Name : </label>
        <input
            type='text'
            name='MovieName'
            onChange={(e)=>  {
                setMovieName(e.target.value)
                console.log(movieName)
        }}
        />
        <label>Review : </label>
        <input
            type='text'
            name='Review'
            onChange={(e)=>  {
                setReview(e.target.value)
                console.log(setReview)
            }}

        />

        <button>Submit</button>
        <Produits/>

        </div>

      </div>
  );
}

export default App;
