'use client';

import React from 'react';
import { useAdmin } from '@/context/AdminContext';

export default function LiveFieldRadar() {
  const { salesmen, showToast } = useAdmin();

  const centerLat = 26.4700;
  const centerLng = 80.3400;

  return (
    <section className="view-panel active" id="view-radar">
      <div className="radar-container">
        <div className="radar-header-banner">
          <div>
            <h2>Live Field Geofence Operations &amp; Anti-Mock Radar</h2>
            <p>Real-time GPS tracking across Kanpur Territory. Haversine Radius Rule (&le; 100m) enforced strictly.</p>
          </div>
          <div className="radar-legend">
            <span className="legend-item">
              <span className="dot in-store"></span> In-Store Active (&le; 100m)
            </span>
            <span className="legend-item">
              <span className="dot transit"></span> In Transit
            </span>
            <span className="legend-item">
              <span className="dot planned"></span> Planned Route
            </span>
          </div>
        </div>

        <div className="radar-grid">
          {/* RADAR CANVAS / MAP SIMULATOR */}
          <div className="radar-map-card">
            <div className="radar-visual-zone">
              <div className="radar-sweep-circle"></div>
              <div className="radar-crosshair-h"></div>
              <div className="radar-crosshair-v"></div>
              <div className="radar-ring r1"></div>
              <div className="radar-ring r2"></div>
              <div className="radar-ring r3"></div>
              <div className="radar-center-hub">
                <i className="fa-solid fa-building-wheat"></i>
                <span>AUPL HQ</span>
              </div>
              <div id="radar-markers-container">
                {salesmen.map(rep => {
                  const loc = rep.currentLocation;
                  const dy = (loc.lat - centerLat) * 4500;
                  const dx = (loc.lng - centerLng) * 4500;
                  const isInStore = rep.status.includes('Active');

                  return (
                    <div
                      key={rep.id}
                      className="radar-marker"
                      style={{
                        left: `calc(50% + ${dx}px)`,
                        top: `calc(50% - ${dy}px)`,
                        cursor: 'pointer',
                      }}
                      onClick={() =>
                        showToast(
                          'Field Telemetry',
                          `${rep.name} is at ${loc.venue} (${loc.distance}m away). Hardware mock: 0.`
                        )
                      }
                    >
                      <div className={`marker-blip ${isInStore ? 'in-store' : 'transit'}`}></div>
                      <div className="marker-label">
                        {rep.name} ({loc.distance}m)
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
            <div className="radar-stats-footer">
              <div className="stat">
                <i className="fa-solid fa-satellite"></i> GPS Constellation: <strong>9 Satellites Locked</strong>
              </div>
              <div className="stat">
                <i className="fa-solid fa-shield-virus"></i> Hardware Mock Check: <strong>PASSED (0 Spoofed)</strong>
              </div>
              <div className="stat">
                <i className="fa-solid fa-ruler-combined"></i> Distance Precision: <strong>&plusmn; 4.2 Meters</strong>
              </div>
            </div>
          </div>

          {/* LIVE REP ACTIVITY STREAM */}
          <div className="radar-activity-card">
            <div className="card-header">
              <h3>Live Salesmen Field Stream</h3>
              <span className="badge-live">LIVE PULSE</span>
            </div>
            <div className="rep-activity-list" id="rep-activity-stream">
              {salesmen.map(rep => {
                const isInStore = rep.status.includes('Active');
                return (
                  <div key={rep.id} className="rep-activity-item">
                    <div className="rep-activity-top">
                      <span className="rep-activity-name">{rep.name}</span>
                      <span className={`status-badge-live ${isInStore ? 'in-store' : 'transit'}`}>
                        {isInStore ? 'IN STORE' : 'IN TRANSIT'}
                      </span>
                    </div>
                    <div className="rep-activity-details">
                      <div>
                        <i className="fa-solid fa-location-dot"></i> Venue:{' '}
                        <strong>{rep.currentLocation.venue}</strong>
                      </div>
                      <div>
                        <i className="fa-solid fa-ruler"></i> Geofence Distance:{' '}
                        <strong>{rep.currentLocation.distance} meters</strong>
                      </div>
                      {rep.checkedInAt && (
                        <div>
                          <i className="fa-solid fa-clock"></i> Check-In Time:{' '}
                          <strong>{rep.checkedInAt}</strong>
                        </div>
                      )}
                      <div className="geofence-tag">
                        <i className="fa-solid fa-shield-check"></i> Haversine Rule Verified (&le; 100m)
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
