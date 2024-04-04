import React from 'react';
import { Pagination } from 'antd';

function Pages() {
  return (
    <div style={{ marginBottom: '0.5% auto', textAlign: 'center' }}>
      <Pagination defaultCurrent={1} total={50} />
    </div>
  );
};

export default Pages;
