function LoadingSpinner({ size = 'medium', className = '' }) {
  const sizeClasses = {
    small: 'spinner-small',
    medium: 'spinner-medium',
    large: 'spinner-large',
  };

  return (
    <div className={`spinner-container ${className}`}>
      <div className={`spinner ${sizeClasses[size]}`}>
        <div className="spinner-ring"></div>
      </div>
    </div>
  );
}

export default LoadingSpinner;